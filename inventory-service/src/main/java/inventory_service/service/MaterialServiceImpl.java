package inventory_service.service;

import inventory_service.domain.Material;
import inventory_service.dto.MaterialRequest;
import inventory_service.dto.MaterialResponse;
import inventory_service.repository.MaterialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MaterialServiceImpl implements MaterialService {

    private final MaterialRepository materialRepository;

    @Override
    public MaterialResponse createMaterial(MaterialRequest request) {
        Material material = Material.builder()
                .name(request.getName())
                .description(request.getDescription())
                .imageUrl(request.getImageUrl())
                .unitPrice(request.getUnitPrice())
                .createdAt(ZonedDateTime.now())
                .build();
        return toResponse(materialRepository.save(material));
    }

    @Override
    public List<MaterialResponse> getAllMaterials() {
        return materialRepository.findAll()
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public MaterialResponse getMaterialById(UUID id) {
        return materialRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new RuntimeException("Material no encontrado"));
    }

    private MaterialResponse toResponse(Material m) {
        return MaterialResponse.builder()
                .id(m.getId())
                .name(m.getName())
                .description(m.getDescription())
                .imageUrl(m.getImageUrl())
                .unitPrice(m.getUnitPrice())
                .createdAt(m.getCreatedAt())
                .build();
    }
}
