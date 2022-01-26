## Init

* ```terraform init```
* ```terraform apply```

## Observe

```
terraform output | awk -F' = ' '{print $2}' | xargs -I {} aws lambda invoke --function-name {} >(cat) > /dev/null
```

## Cleanup

* ```terraform destroy```
