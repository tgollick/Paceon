# Run Models
from dataclasses import dataclass
from enum import Enum
from datetime import timedelta
from uuid import UUID


# Enum for metric conversion to be used in later functions
class Metric(Enum):
    KILOMETERS = "Kilometers"
    MILES = "Miles"


# Class representing interval, 1 or many found present inside of a run class
@dataclass
class Interval:
    id: UUID
    distance: float
    target_pace: timedelta
    metric: Metric


# Classes representing post run data
@dataclass
class IntervalMetadata:
    id: UUID
    distance: float
    pace: timedelta
    metric: Metric


@dataclass
class RunMetadata:
    id: UUID
    distance: float
    average_pace: timedelta
    metric: Metric
    rpe: int


# Class representing the run data and post run metadata
@dataclass
class Run:
    id: UUID
    data: list[Interval]
    expected_duration: timedelta
    total_distance: float
    interval_metadata: list[IntervalMetadata]
    run_metadata: RunMetadata
    complete: bool
