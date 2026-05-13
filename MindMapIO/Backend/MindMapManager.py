import json
import os
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property, QPointF
import math


class MindMapManager(QObject):
    """Manages the MindMap data model and file I/O."""

    mapLoadedChanged = Signal()
    nodesChanged = Signal()
    edgesChanged = Signal()
    currentFileChanged = Signal()
    errorOccurred = Signal(str)
    mapTitleChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._nodes = []   # list of dicts
        self._edges = []   # list of {source, target}
        self._current_file = ""
        self._map_loaded = False
        self._map_title = "Untitled MindMap"
        self._next_id = 1

    # ──────────────────────────── Properties ────────────────────────────────

    @Property(bool, notify=mapLoadedChanged)
    def mapLoaded(self):
        return self._map_loaded

    @Property(str, notify=currentFileChanged)
    def currentFile(self):
        return self._current_file

    @Property(str, notify=mapTitleChanged)
    def mapTitle(self):
        return self._map_title

    @Property(list, notify=nodesChanged)
    def nodes(self):
        return self._nodes

    @Property(list, notify=edgesChanged)
    def edges(self):
        return self._edges

    # ──────────────────────────── Slots ─────────────────────────────────────

    @Slot(str, str)
    def createNewMap(self, file_path: str, title: str):
        """Create a brand-new mind-map file and initialize with a root node."""
        try:
            if not file_path.endswith(".json"):
                file_path += ".json"

            self._nodes = []
            self._edges = []
            self._next_id = 1
            self._map_title = title or "Untitled MindMap"
            self._current_file = file_path

            # Root node placed at center
            root = {
                "id": "node_1",
                "label": self._map_title,
                "x": 600,
                "y": 400,
                "color": "#6366f1",
                "isRoot": True,
                "level": 0,
            }
            self._nodes.append(root)
            self._next_id = 2

            self._save()
            self._map_loaded = True
            self.mapLoadedChanged.emit()
            self.nodesChanged.emit()
            self.edgesChanged.emit()
            self.currentFileChanged.emit()
            self.mapTitleChanged.emit()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(str)
    def openMap(self, file_path: str):
        """Load an existing mind-map JSON file."""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)

            self._nodes = data.get("nodes", [])
            self._edges = data.get("edges", [])
            self._map_title = data.get("title", "Untitled MindMap")
            self._current_file = file_path

            # Recalculate next id
            ids = [int(n["id"].split("_")[1]) for n in self._nodes if "_" in n.get("id", "")]
            self._next_id = (max(ids) + 1) if ids else 1

            self._map_loaded = True
            self.mapLoadedChanged.emit()
            self.nodesChanged.emit()
            self.edgesChanged.emit()
            self.currentFileChanged.emit()
            self.mapTitleChanged.emit()
        except Exception as e:
            self.errorOccurred.emit(str(e))

    @Slot(str, result=str)
    def addChildNode(self, parent_id: str) -> str:
        """Add a child node to the given parent. Returns the new node id."""
        try:
            parent = next((n for n in self._nodes if n["id"] == parent_id), None)
            if parent is None:
                self.errorOccurred.emit(f"Parent node {parent_id} not found")
                return ""

            new_id = f"node_{self._next_id}"
            self._next_id += 1

            level = parent.get("level", 0) + 1
            # Offset child relative to parent
            angle = self._compute_child_angle(parent_id)
            radius = 220
            cx = parent["x"] + radius * math.cos(angle)
            cy = parent["y"] + radius * math.sin(angle)

            colors = ["#6366f1", "#8b5cf6", "#06b6d4", "#10b981", "#f59e0b", "#ef4444"]
            color = colors[level % len(colors)]

            new_node = {
                "id": new_id,
                "label": "New Node",
                "x": cx,
                "y": cy,
                "color": color,
                "isRoot": False,
                "level": level,
            }
            self._nodes.append(new_node)
            self._edges.append({"source": parent_id, "target": new_id})

            self._save()
            self.nodesChanged.emit()
            self.edgesChanged.emit()
            return new_id
        except Exception as e:
            self.errorOccurred.emit(str(e))
            return ""

    @Slot(str, str)
    def updateNodeLabel(self, node_id: str, label: str):
        """Rename a node."""
        for n in self._nodes:
            if n["id"] == node_id:
                n["label"] = label
                break
        self._save()
        self.nodesChanged.emit()

    @Slot(str, float, float)
    def updateNodePosition(self, node_id: str, x: float, y: float):
        """Update node position after drag."""
        for n in self._nodes:
            if n["id"] == node_id:
                n["x"] = x
                n["y"] = y
                break
        self._save()
        self.nodesChanged.emit()

    @Slot(str)
    def deleteNode(self, node_id: str):
        """Delete a node and all descendants recursively."""
        if node_id == "node_1":
            self.errorOccurred.emit("Cannot delete root node")
            return
        to_delete = self._collect_descendants(node_id)
        to_delete.add(node_id)
        self._nodes = [n for n in self._nodes if n["id"] not in to_delete]
        self._edges = [e for e in self._edges if e["source"] not in to_delete and e["target"] not in to_delete]
        self._save()
        self.nodesChanged.emit()
        self.edgesChanged.emit()

    @Slot()
    def saveMap(self):
        self._save()

    # ──────────────────────────── Helpers ────────────────────────────────────

    def _collect_descendants(self, node_id: str) -> set:
        result = set()
        children = [e["target"] for e in self._edges if e["source"] == node_id]
        for c in children:
            result.add(c)
            result.update(self._collect_descendants(c))
        return result

    def _compute_child_angle(self, parent_id: str) -> float:
        """Pick an angle that avoids existing children."""
        existing_children = [e["target"] for e in self._edges if e["source"] == parent_id]
        parent = next(n for n in self._nodes if n["id"] == parent_id)
        used_angles = []
        for cid in existing_children:
            child = next((n for n in self._nodes if n["id"] == cid), None)
            if child:
                used_angles.append(math.atan2(child["y"] - parent["y"], child["x"] - parent["x"]))

        # Try angles spread around the circle; pick the one farthest from used
        candidates = [i * (2 * math.pi / 8) for i in range(8)]
        if not used_angles:
            return 0.0
        best = max(candidates, key=lambda a: min(abs(a - u) for u in used_angles))
        return best

    def _save(self):
        if not self._current_file:
            return
        data = {
            "title": self._map_title,
            "nodes": self._nodes,
            "edges": self._edges,
        }
        os.makedirs(os.path.dirname(os.path.abspath(self._current_file)), exist_ok=True)
        with open(self._current_file, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
