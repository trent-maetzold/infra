/**
 * Approve `edit`/`write` targets that leave the session working directory.
 *
 * The host resolves approval policy per tool name (`tools.approval.<tool>`), so
 * a path-conditional gate has no declarative setting; this `tool_call` handler
 * is that gate. Targets inside the working directory run untouched. A target
 * outside it — or a remote host reached over `ssh://` — asks the user first,
 * and a session with no interactive UI (print mode, headless subagents) fails
 * closed instead of guessing.
 *
 * Covers the `edit` and `write` tools, including the `ast_edit` device the
 * `write` tool dispatches. `bash` and `eval` reach the filesystem through a
 * process, not a path argument; those are governed by `bash.patterns`.
 */
import { realpathSync } from "node:fs";
import { basename, dirname, isAbsolute, join, relative, resolve } from "node:path";

interface ToolCallEvent {
	toolName: string;
	input: Record<string, unknown>;
}

interface GuardrailContext {
	cwd: string;
	hasUI: boolean;
	ui: {
		confirm(title: string, message: string): Promise<boolean>;
	};
}

interface GuardrailApi {
	on(event: "tool_call", handler: (event: ToolCallEvent, ctx: GuardrailContext) => Promise<unknown>): void;
}

const GUARDED_TOOLS: Record<string, true> = {edit: true, write: true};
/** Any internal URL, `xd://` device, or absolute Windows path (`C:\...`). */
const SCHEME = /^[a-z][a-z0-9+.-]*:\/\//i;
/** Writes that run on another host; already exec-tier, and always worth asking about. */
const REMOTE = /^ssh:\/\//i;
/** The `write` device that rewrites workspace files. */
const AST_EDIT_DEVICE = /^xd:\/\/ast_edit$/i;
/** apply_patch and sloppy edit modes carry their targets in the payload, not a `path`. */
const PATCH_TARGET = /^\*\*\* (?:(?:Add|Update|Delete) File|Move to): (.+)$/;
const HOME = process.env.HOME;

/**
 * Strip a copied `[path]` / `[path#TAG]` hashline wrapper, as the write and
 * edit tools do before touching the filesystem.
 */
function unwrap(authored: string): string {
	const trimmed = authored.trim();
	if (!trimmed.startsWith("[") || !trimmed.endsWith("]")) return trimmed;
	const inner = trimmed.slice(1, -1);
	const tag = /#[0-9a-fA-F]{4}$/.exec(inner);
	const path = tag ? inner.slice(0, tag.index) : inner;
	return path.length > 0 && !path.includes("#") ? path : trimmed;
}

/** Every authored target of the call, `xd://ast_edit` payloads included. */
function authoredPaths(input: Record<string, unknown>): string[] {
	const found = new Set<string>();
	const add = (value: unknown): void => {
		if (typeof value === "string" && value.trim().length > 0) found.add(value.trim());
	};

	add(input.path);
	add(input._path);
	if (Array.isArray(input.paths)) for (const path of input.paths) add(path);

	const device = typeof input.path === "string" && AST_EDIT_DEVICE.test(unwrap(input.path));
	if (device && typeof input.content === "string") {
		try {
			const payload = JSON.parse(input.content) as {path?: unknown; paths?: unknown};
			add(payload.path);
			if (Array.isArray(payload.paths)) for (const path of payload.paths) add(path);
		} catch {
			// Malformed device payloads fail in the device itself; nothing to scope here.
		}
	}

	if (found.size === 0) {
		const patch = typeof input.input === "string" ? input.input : input._input;
		if (typeof patch === "string") {
			for (const line of patch.split("\n")) {
				const match = PATCH_TARGET.exec(line.trim());
				if (match) add(match[1]);
			}
		}
	}

	return [...found];
}

/**
 * The filesystem path behind a target, or undefined for anything that is not a
 * plain file: internal URLs and devices resolve somewhere else, and the host
 * gates those on their own terms.
 */
function fileTarget(authored: string): string | undefined {
	const path = unwrap(authored);
	if (path.length === 0 || SCHEME.test(path)) return undefined;
	// `archive.zip:entry` and `db.sqlite:table:key` select inside a real file.
	const selector = path.indexOf(":");
	return selector === -1 ? path : path.slice(0, selector);
}

/** Realpath of a path that may not exist yet, falling back to its nearest existing ancestor. */
function canonical(path: string): string {
	try {
		return realpathSync.native(path);
	} catch {
		try {
			return join(realpathSync.native(dirname(path)), basename(path));
		} catch {
			return resolve(path);
		}
	}
}

function absolute(authored: string, cwd: string): string {
	const expanded = HOME !== undefined && authored.startsWith("~/") ? join(HOME, authored.slice(2)) : authored;
	return canonical(isAbsolute(expanded) ? expanded : resolve(cwd, expanded));
}

function isInside(target: string, root: string): boolean {
	if (target === root) return true;
	const rest = relative(root, target);
	return rest.length > 0 && !rest.startsWith("..") && !isAbsolute(rest);
}

export default function guardrails(pi: GuardrailApi): void {
	pi.on("tool_call", async (event, ctx) => {
		if (GUARDED_TOOLS[event.toolName] !== true) return;

		const root = canonical(ctx.cwd);
		const outside: string[] = [];
		for (const authored of authoredPaths(event.input)) {
			if (REMOTE.test(unwrap(authored))) {
				outside.push(`${authored} — remote host`);
				continue;
			}
			const path = fileTarget(authored);
			if (path === undefined) continue;
			const target = absolute(path, ctx.cwd);
			if (!isInside(target, root)) outside.push(path === target ? target : `${path} → ${target}`);
		}
		if (outside.length === 0) return;

		const detail = `Working directory: ${root}\n\n${outside.map(target => `- ${target}`).join("\n")}`;
		if (!ctx.hasUI) {
			return {
				block: true,
				reason: `guardrails: ${event.toolName} needs approval for a path outside the working directory, and this session has no UI to ask in.\n${detail}`,
			};
		}
		const approved = await ctx.ui.confirm(`Approve ${event.toolName} outside the working directory`, detail);
		if (approved) return;
		return {
			block: true,
			reason: `guardrails: ${event.toolName} outside the working directory was not approved.\n${detail}`,
		};
	});
}
