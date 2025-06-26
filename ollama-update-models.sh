#!/bin/bash

docker exec -it ollama bash -c '
for model in $(ollama list | tail -n +2 | awk "{print \$1}"); do
  echo "Updating model: $model"
  ollama pull $model
done
'
