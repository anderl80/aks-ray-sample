import ray

ray.init()

@ray.remote
def f():
  import emoji
  import mlflow
  #mlflow.set_tracking_uri("databricks")
  #mlflow.set_experiment("/Users/andreas.hopfgartner@microsoft.com/hello-world-experiment")
  #with mlflow.start_run():
  #  mlflow.log_metric("hello_world_metric", 1)
  return emoji.emojize('Python is :thumbs_up:')

print(ray.get(f.remote()))