# Smoke-tests the three service images: loopback start, unauthenticated MCP rejection,
# and the artifact-server stdio bridge. Leaves no containers or volumes behind.

import json
import secrets
import selectors
import subprocess
import time
import urllib.error
import urllib.request

containers = []
volumes = ['asgard-test-dagu', 'asgard-test-kaneo-db', 'asgard-test-artifact']
network = 'asgard-test-kaneo'

def run(*args):
    return subprocess.run(['podman', *args], check=True, capture_output=True, text=True).stdout.strip()

def start(name, *args):
    run('run', '-d', '--name', name, *args)
    containers.append(name)

def wait_http(url, expected=200):
    for _ in range(90):
        try:
            with urllib.request.urlopen(url, timeout=2) as response:  # noqa: S310
                assert response.status == expected
                return
        except OSError:
            time.sleep(1)
    raise RuntimeError('Service never became ready: ' + url)

def unauthorized(url):
    request = urllib.request.Request(url, data=json.dumps({'jsonrpc':'2.0','id':1,'method':'initialize','params':{'protocolVersion':'2024-11-05','capabilities':{},'clientInfo':{'name':'asgard-smoke','version':'1'}}}).encode(), headers={'Content-Type':'application/json','Accept':'application/json, text/event-stream'})
    # A freshly started server can drop the first connection while it settles.
    for _ in range(30):
        try:
            urllib.request.urlopen(request, timeout=10)  # noqa: S310
        except urllib.error.HTTPError as error:
            assert error.code in {401, 403}, error.code
            return
        except OSError:
            time.sleep(1)
            continue
        raise AssertionError('Unauthenticated MCP request was accepted')
    raise AssertionError('MCP endpoint never answered: ' + url)

try:
    start('asgard-test-dagu', '-p', '127.0.0.1:18080:8080', '-v', volumes[0]+':/var/lib/dagu', '-e','DAGU_HOST=0.0.0.0','-e','DAGU_PORT=8080','-e','DAGU_AUTH_MODE=builtin','-e','DAGU_DAGS_DIR=/var/lib/dagu/dags','ghcr.io/dagucloud/dagu:2.25.2','dagu','start-all')
    wait_http('http://127.0.0.1:18080/setup')
    unauthorized('http://127.0.0.1:18080/mcp')
    print('PASS: Dagu starts with a persistent volume; setup page works; MCP rejects unauthenticated requests.', flush=True)
    run('network','create',network)
    password=secrets.token_hex(24)
    start('asgard-test-kaneo-db','--network',network,'--network-alias','kaneo-db','-v',volumes[1]+':/var/lib/postgresql/data','-e','POSTGRES_USER=kaneo','-e','POSTGRES_DB=kaneo','-e','POSTGRES_PASSWORD='+password,'docker.io/library/postgres:16-alpine')
    for _ in range(60):
        result=subprocess.run(['podman','exec','asgard-test-kaneo-db','pg_isready','-U','kaneo','-d','kaneo'],capture_output=True)
        if result.returncode == 0:
            break
        time.sleep(1)
    else:
        raise RuntimeError('PostgreSQL did not become ready')
    start('asgard-test-kaneo','--network',network,'-p','127.0.0.1:15173:5173','-e','POSTGRES_HOST=kaneo-db','-e','POSTGRES_DB=kaneo','-e','POSTGRES_USER=kaneo','-e','POSTGRES_PASSWORD='+password,'-e','AUTH_SECRET='+secrets.token_hex(32),'-e','KANEO_CLIENT_URL=http://localhost:15173','ghcr.io/usekaneo/kaneo:2.49.0')
    wait_http('http://127.0.0.1:15173/api/health')
    unauthorized('http://127.0.0.1:15173/api/mcp')
    wait_http('http://127.0.0.1:15173/.well-known/oauth-protected-resource/api/mcp')
    print('PASS: Kaneo starts with PostgreSQL; health and OAuth discovery work; MCP rejects unauthenticated requests.', flush=True)
    start('asgard-test-artifact','--network','host','-v',volumes[2]+':/var/lib/artifact-server:U','ghcr.io/plannotator/artifact-server@sha256:e832267831dddd905d158aeeb6b331ef314c7d4737c8769d7bd335b91bd43055','start','--managed','--data','/var/lib/artifact-server/data','--port','18788')
    wait_http('http://127.0.0.1:18788/health')
    bridge=subprocess.Popen(['podman','exec','-i','asgard-test-artifact','node','dist/cli/main.js','mcp','--data','/var/lib/artifact-server/data'],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
    assert bridge.stdin and bridge.stdout
    def rpc(message):
        bridge.stdin.write(json.dumps(message)+'\n')
        bridge.stdin.flush()
    def receive():
        selector=selectors.DefaultSelector()
        selector.register(bridge.stdout,selectors.EVENT_READ)
        if not selector.select(30):
            raise RuntimeError('Artifact MCP response timed out')
        return json.loads(bridge.stdout.readline())
    try:
        rpc({'jsonrpc':'2.0','id':1,'method':'initialize','params':{'protocolVersion':'2024-11-05','capabilities':{},'clientInfo':{'name':'asgard-smoke','version':'1'}}})
        initialized=receive()
        assert 'result' in initialized, initialized
        rpc({'jsonrpc':'2.0','method':'notifications/initialized'})
        rpc({'jsonrpc':'2.0','id':2,'method':'tools/list','params':{}})
        listed=receive()
        assert listed['result']['tools']
        print('PASS: Artifact Server starts on loopback; authenticated stdio bridge initializes and lists '+str(len(listed['result']['tools']))+' tools.', flush=True)
    finally:
        bridge.terminate()
        bridge.wait(timeout=10)
finally:
    for container in reversed(containers):
        subprocess.run(['podman','rm','-f',container],capture_output=True)
    for volume in volumes:
        subprocess.run(['podman','volume','rm',volume],capture_output=True)
    subprocess.run(['podman','network','rm',network],capture_output=True)
