# Running jobs on KubeRay

Please check the [Ray Documentation](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/rayjob-quick-start.html) how to run jobs on KubeRay.

## How to run the hello world example on an existing Ray cluster

```bash
# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Submit the Ray job
ray job submit --working-dir . --runtime-env-json='{"pip": ["emoji", "mlflow"], "env_vars": {"DATABRICKS_HOST": "'"$DATABRICKS_HOST"'", "DATABRICKS_TOKEN": "'"$DATABRICKS_TOKEN"'"}}' -- python hello_world.py
```
