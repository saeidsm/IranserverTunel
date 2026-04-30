# API Keys Setup

The deep test feature verifies that your tunnels can actually reach AI services with valid API keys. To enable this, create a keys file at `/home/ubuntu/.api_keys`:

## Template

```bash
# /home/ubuntu/.api_keys
export GEMINI_KEY="your_gemini_api_key"
export BFL_KEY="your_blackforestlabs_api_key"
export EL_KEY="your_elevenlabs_api_key"
```

## Important security notes

1. **chmod 600 the file**:
   ```bash
   chmod 600 /home/ubuntu/.api_keys
   ```

2. **Never commit this file to git.**

3. **Use IP-restricted keys when possible.** For Gemini, you can restrict the key to the IP of the exit servers your tunnels use.

4. **Use separate keys per environment.** Don't reuse production keys for testing.

## How keys are used

When you run `tunnel-mgr test NAME` or `tunnel-mgr test-all`:
1. The script sources the keys file
2. For each tunnel, makes a real API call (small, low-cost) to each service
3. Records pass/fail in the state file
4. Determines if tunnel is "qualified" (all keys pass)

The keys are NEVER logged or written to any file other than this single env file.

## What if I don't want deep tests?

Just don't create the keys file. Quick health checks (every 15min) only need TCP reachability and don't use any API key. Tunnels will still be added to the pool based on basic reachability.

However, you won't know if specific services (e.g., ElevenLabs) actually work through each tunnel until you make real requests from your application.

## Where to get keys

- **Gemini**: https://aistudio.google.com/apikey
- **BFL (FLUX)**: https://api.bfl.ai/dashboard
- **ElevenLabs**: https://elevenlabs.io/app/settings/api-keys
