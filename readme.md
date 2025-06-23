apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: opx1-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-csi
  resources:
    requests:
      storage: 10Gi













apiVersion: apps/v1
kind: Deployment
metadata:
  name: opx1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: opx1
  template:
    metadata:
      labels:
        app: opx1
    spec:
      containers:
      - name: opx1
        image: <your-acr-name>.azurecr.io/opx1:latest
        volumeMounts:
        - name: opx-volume
          mountPath: /var/opx
          subPath: opx
        - name: opx-volume
          mountPath: /var/log/opx
          subPath: log-opx
        - name: opx-volume
          mountPath: /opt/tomcat/logs
          subPath: tomcat-logs
        ports:
        - containerPort: 8009
      volumes:
      - name: opx-volume
        persistentVolumeClaim:
          claimName: opx1-pvc
