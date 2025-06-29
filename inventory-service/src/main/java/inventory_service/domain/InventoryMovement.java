package inventory_service.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "inventory_movements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryMovement {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "material_id", nullable = false)
    private UUID materialId;

    @Column(name = "project_id")
    private UUID projectId; // puede ser null

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "movement_type", nullable = false, length = 10)
    private String movementType; // 'IN' o 'OUT'

    @Column(name = "movement_date", nullable = false)
    private ZonedDateTime movementDate;
}
