
1. Create Dockerfile 
2. RUN docker build
```azure
docker build -t go-end2-end:v1 .
```
3. create container
```azure
docker run -p 8080:8080 -it -d go-end2-end:v1 
```


4. Login Docker hub 

```azure
docker login
```
```
docker tag go-end2-end:v1 rifky86/go-end2-end:v1
```
```azure
docker push rifky86/go-end2-end:v1
```



### CREATE K8S

1. creat folder k8s
2. create folder k8s/manifest 
3. create deployment.yaml


