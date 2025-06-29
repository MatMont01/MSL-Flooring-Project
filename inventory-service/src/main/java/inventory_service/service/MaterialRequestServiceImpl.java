package inventory_service.service;

import inventory_service.domain.InventoryMovement;
import inventory_service.domain.MaterialRequest;
import inventory_service.dto.MaterialRequestCreateDTO;
import inventory_service.dto.MaterialRequestResponseDTO;
import inventory_service.repository.InventoryMovementRepository;
import inventory_service.repository.MaterialRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MaterialRequestServiceImpl implements MaterialRequestService {

    private final MaterialRequestRepository repo;
    private final InventoryMovementRepository movementRepo;

    @Override
    public MaterialRequestResponseDTO createRequest(MaterialRequestCreateDTO dto) {
        MaterialRequest request = MaterialRequest.builder()
                .projectId(dto.getProjectId())
                .materialId(dto.getMaterialId())
                .quantity(dto.getQuantity())
                .status("PENDING")
                .requestedAt(ZonedDateTime.now())
                .build();
        return toResponse(repo.save(request));
    }

    @Override
    public List<MaterialRequestResponseDTO> getPendingRequests() {
        return repo.findByStatus("PENDING").stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public MaterialRequestResponseDTO approveRequest(UUID requestId) {
        MaterialRequest request = repo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Solicitud no encontrada"));
        request.setStatus("APPROVED");
        request.setApprovedAt(ZonedDateTime.now());
        repo.save(request);

        // Registrar salida de inventario
        InventoryMovement movement = InventoryMovement.builder()
                .materialId(request.getMaterialId())
                .projectId(request.getProjectId())
                .quantity(request.getQuantity())
                .movementType("OUT")
                .movementDate(ZonedDateTime.now())
                .build();
        movementRepo.save(movement);

        return toResponse(request);
    }

    @Override
    public List<MaterialRequestResponseDTO> getRequestsByProject(UUID projectId) {
        return repo.findByProjectId(projectId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private MaterialRequestResponseDTO toResponse(MaterialRequest mr) {
        return MaterialRequestResponseDTO.builder()
                .id(mr.getId())
                .projectId(mr.getProjectId())
                .materialId(mr.getMaterialId())
                .quantity(mr.getQuantity())
                .status(mr.getStatus())
                .requestedAt(mr.getRequestedAt())
                .approvedAt(mr.getApprovedAt())
                .build();
    }
}
