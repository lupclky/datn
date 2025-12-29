package com.example.Sneakers.services.storage;

import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GoogleCloudStorageService implements IStorageService {

    @Value("${gcp.storage.bucket-name}")
    private String bucketName;

    private final Storage storage = StorageOptions.getDefaultInstance().getService();

    @Override
    public String storeFile(MultipartFile file) throws IOException {
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            throw new IOException("Invalid file name");
        }
        String fileName = UUID.randomUUID().toString() + "_" + StringUtils.cleanPath(originalFilename);
        
        BlobId blobId = BlobId.of(bucketName, fileName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setContentType(file.getContentType()).build();
        
        Blob blob = storage.create(blobInfo, file.getBytes());
        
        // Return the public URL
        return "https://storage.googleapis.com/" + bucketName + "/" + fileName;
    }

    @Override
    public void deleteFile(String fileUrl) {
        try {
            // Extract filename from URL
            // URL format: https://storage.googleapis.com/BUCKET_NAME/FILE_NAME
            String fileName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
            BlobId blobId = BlobId.of(bucketName, fileName);
            storage.delete(blobId);
        } catch (Exception e) {
            System.err.println("Error deleting file: " + e.getMessage());
        }
    }
}
