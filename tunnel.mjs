import localtunnel from 'localtunnel';
const tunnel = await localtunnel({ port: 4747, subdomain: 'yunustuncel-agentation' });
process.stdout.write(tunnel.url + '\n');
tunnel.on('error', (e) => { process.stderr.write(e.message + '\n'); });
tunnel.on('close', () => process.exit(0));
