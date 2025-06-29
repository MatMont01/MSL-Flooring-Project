package inventory_service.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "tool_assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ToolAssignment {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "tool_id", nullable = false)
    private UUID toolId;

    @Column(name = "worker_id")
    private UUID workerId; // puede ser null (si es asignación a proyecto)

    @Column(name = "project_id")
    private UUID projectId; // puede ser null (si es préstamo a trabajador)

    @Column(name = "assigned_at", nullable = false)
    private ZonedDateTime assignedAt;

    @Column(name = "due_date")
    private ZonedDateTime dueDate;

    @Column(name = "returned_at")
    private ZonedDateTime returnedAt;
}
