# 🚀 Azure File Upload from VM using AzCopy + SAS

This document outlines the steps taken to **upload files from an Azure Linux VM to an Azure File Share** using `azcopy` and a SAS token. The VM could not use `az login` interactively, so we used an alternate identity-based + token-auth method.

---

## 🧭 Objective

- ✅ Copy a folder containing multiple files from an Azure VM  
- ✅ Target: Azure File Share (`<file-share-name>`) inside storage account `<storage-account-name>`  
- ✅ Use AzCopy and a temporary SAS token for authentication  

---

## ⚙️ Environment

- **VM OS**: RHEL on Azure  
- **Storage Account**: `<storage-account-name>`  
- **File Share**: `<file-share-name>`  
- **Tool**: [AzCopy v10](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10)  

---

## 🛠️ Step-by-Step Process

### 1. Enable System-Assigned Managed Identity for the VM

```bash
az vm identity assign \
  --name <vm-name> \
  --resource-group <resource-group-name>
```

---

### 2. Assign RBAC Permissions (Initial Attempt)

```bash
az role assignment create \
  --assignee <principal-id> \
  --role "Storage File Data SMB Share Contributor" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>
```

> ❗ Note: AzCopy to Azure File Share with managed identity **requires Azure AD DS + Kerberos**, which was not configured in this case.

---

### 3. Generate a SAS Token for File Share Access

```bash
az storage share generate-sas \
  --account-name <storage-account-name> \
  --name <file-share-name> \
  --permissions rwlc \
  --expiry 2025-08-02T00:00Z \
  --output tsv
```

---

### 4. Install AzCopy on the VM

```bash
wget https://aka.ms/downloadazcopy-v10-linux -O azcopy.tar.gz
tar -xf azcopy.tar.gz
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
sudo chmod +x /usr/bin/azcopy
azcopy --version
```

---

### 5. Upload Files Using AzCopy + SAS Token

```bash
azcopy copy "/home/<linux-user>/<folder>/*" "https://<storage-account-name>.file.core.windows.net/<file-share-name>?<sas-token>" --recursive=true
```

---

## 🧠 Learnings

- Managed Identity + RBAC does **not** work for Azure File Share with AzCopy unless AAD DS (Azure Active Directory Domain Services) is configured  
- SAS token is the **most reliable method** for uploading files to Azure File Share from CLI-based VMs  
- AzCopy is a **fast and scalable** utility for bulk file transfers  

---

## 📁 Helpful Commands

### List all storage accounts

```bash
az storage account list --query "[].name" --output table
```

### List file shares in a storage account

```bash
az storage share list \
  --account-name <storage-account-name> \
  --auth-mode login
```

---

## 📎 References

- [AzCopy Docs](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10)  
- [Azure Files + Azure AD DS](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-active-directory-overview)  

---

_Authored by: Deepak Sharma_  
_Date: 2025-08-01_
