# Plan Model
from dataclasses import dataclass
from enum import Enum
from uuid import UUID
from backend.models.run import Run


class PlanType(Enum):
    MARATHON = "Marathon"
    HALFMARATHON = "Half Marathon"
    TENKM = "10KM"
    FIVEKM = "5KM"


@dataclass
class Plan:
    id: UUID
    runs: list[Run]
    completion: float
    plantype: PlanType
    progress: float
