package com.example.notification_service.service;

import com.example.notification_service.domain.Document;
import com.example.notification_service.dto.DocumentResponse;
import com.example.notification_service.repository.DocumentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileOutputStream;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DocumentServiceImpl implements DocumentService {

    private final DocumentRepository documentRepository;

    private final String uploadPath = "./uploads/"; // Puedes cambiar por S3 más adelante

    @Override
    public DocumentResponse uploadDocument(String filename, MultipartFile file, UUID uploadedBy, UUID projectId) {
        try {
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();

            String uniqueName = UUID.randomUUID() + "_" + filename;
            File outFile = new File(uploadPath + uniqueName);
            try (FileOutputStream fos = new FileOutputStream(outFile)) {
                fos.write(file.getBytes());
            }

            Document document = Document.builder()
                    .filename(filename)
                    .fileUrl(outFile.getAbsolutePath())
                    .uploadedBy(uploadedBy)
                    .projectId(projectId)
                    .uploadedAt(ZonedDateTime.now())
                    .build();

            return toResponse(documentRepository.save(document));
        } catch (Exception e) {
            throw new RuntimeException("No se pudo guardar el archivo: " + e.getMessage());
        }
    }

    @Override
    public List<DocumentResponse> getAllDocuments() {
        return documentRepository.findAll()
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<DocumentResponse> getDocumentsByProject(UUID projectId) {
        return documentRepository.findByProjectId(projectId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public DocumentResponse getDocumentById(UUID id) {
        Document doc = documentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Documento no encontrado"));
        return toResponse(doc);
    }

    @Override
    public void deleteDocument(UUID id) {
        documentRepository.deleteById(id);
    }

    private DocumentResponse toResponse(Document d) {
        return DocumentResponse.builder()
                .id(d.getId())
                .filename(d.getFilename())
                .fileUrl(d.getFileUrl())
                .uploadedBy(d.getUploadedBy())
                .projectId(d.getProjectId())
                .uploadedAt(d.getUploadedAt())
                .build();
    }
}
