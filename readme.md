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


apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: opx1-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  volumeName: opx1-pv










apiVersion: v1
kind: PersistentVolume
metadata:
  name: opx1-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: file.csi.azure.com
    readOnly: false
    volumeHandle: <storage-account-name>#<file-share-name>
    volumeAttributes:
      storageAccount: <storage-account-name>
    nodeStageSecretRef:
      name: azure-secret
      namespace: default









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
