extends Node

static var rng:RandomNumberGenerator = RandomNumberGenerator.new()

static func generate_features(heightmap:Image, subdivisions:int, city_count:int = 5, road_density:float = 1.0, river_density:float = 1.0, map_seed:int = 0) -> Image:
	rng.seed = map_seed
	var w:int = heightmap.get_width()
	var h:int = heightmap.get_height()
	
	var features:Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	features.fill(Color(0,0,0,1))
	
	## Step 1. Place cities
	var cities:Array[Vector2i] = _generate_cities(w, h, city_count, 20.0)  ## 20 pixels min distance
	for city in cities:
		var radius:int = rng.randi_range(6, 12)
		_flatten_area(heightmap, features, city, radius)
	
	## Step 2. Create roads
	_draw_road_network(features, cities, road_density, 0.3)
	
	## Step 3. Generate rivers
	var river_sources:Array[Vector2i] = _find_river_sources(heightmap, river_density)
	for src in river_sources:
		_trace_river(heightmap, features, src)
	
	features.resize(w * subdivisions, h * subdivisions, Image.INTERPOLATE_CUBIC)
	
	return features

## Place cities using Poisson disk sampling
static func _generate_cities(w:int, h:int, city_count:int, min_distance:float) -> Array[Vector2i]:
	var cities:Array[Vector2i] = []
	var attempts:int = 0
	var max_attempts:int = city_count * 20
	
	while cities.size() < city_count and attempts < max_attempts:
		var cx:int = rng.randi_range(0, w-1)
		var cy:int = rng.randi_range(0, h-1)
		var candidate:Vector2i = Vector2i(cx, cy)
		var valid:bool = true
		for city in cities:
			if city.distance_to(candidate) < min_distance:
				valid = false
				break
		if valid:
			cities.append(candidate)
		attempts += 1
	
	return cities

## Flatten areas around Cities
static func _flatten_area(heightmap:Image, features:Image, center:Vector2i, radius:int) -> void:
	var cx:int = center.x
	var cy:int = center.y
	var base_h:int = roundi(heightmap.get_pixel(cx, cy).r * 255.0)
	for x in range(-radius, radius+1):
		for y in range(-radius, radius+1):
			var px:int = cx + x
			var py:int = cy + y
			if px < 0 or py < 0 or px >= heightmap.get_width() or py >= heightmap.get_height():
				continue
			if Vector2(x,y).length() <= float(radius):
				# flatten heightmap to base_h
				heightmap.set_pixel(px, py, Color(base_h/255.0, 0, 0))
				# mark city area in green
				var c:Color = features.get_pixel(px, py)
				features.set_pixel(px, py, Color(c.r, 1.0, c.b, 0))

static func _draw_road_network(features:Image, cities:Array[Vector2i], road_density:float = 1.0, road_offset_factor:float = 1.0) -> void:
	var connected:Dictionary = {}
	var queue:Array[Array] = []

	# seed with city-to-city main connections
	queue = _compute_mst_with_extra_edges(cities, road_density)

	while queue.size() > 0:
		var pair:Array = queue.pop_front()
		var start:Vector2i = pair[0]
		var goal:Vector2i = pair[1]

		var key := str(start) + "_" + str(goal)
		if connected.has(key):
			continue
		connected[key] = true

		# generate the segmented spline road
		var new_nodes:Array[Vector2] = _generate_road(features, start, goal, road_density, road_offset_factor)

		# branching check:enqueue new potential connections
		for node in new_nodes:
			for city in cities:
				if city == start or city == goal:
					continue
				if city.distance_squared_to(node) < 24.0**2 and rng.randf() < road_density:# within branch distance
					queue.append([node, city])


static func _generate_road(features:Image, start:Vector2i, goal:Vector2i, road_density:float, offset_factor:float) -> Array[Vector2]:
	var distance:float = start.distance_to(goal)
	var num_nodes:int = max(1, int(distance / 32.0)) # ~120 units per node

	var direction:Vector2 = Vector2(goal - start).normalized()
	var perpendicular_direction:Vector2 = Vector2(-direction.y, direction.x)

	var nodes:Array[Vector2] = [Vector2(start)]
	for i in range(1, num_nodes):
		var t:float = float(i) / float(num_nodes)
		var base:Vector2 = Vector2(start).lerp(goal, t)

		# sideways offset for wandering
		var offset:float = rng.randf_range(-offset_factor, offset_factor)
		var node_point:Vector2 = base + perpendicular_direction * offset * base.length()
		if node_point.x >= 0 and node_point.x < features.get_width() and node_point.y >= 0 and node_point.y < features.get_height():
			nodes.append(base + perpendicular_direction * offset)

	nodes.append(Vector2(goal))

	# draw splines between nodes
	for j in range(nodes.size() - 1):
		_draw_bezier_segment(features, nodes[j], nodes[j + 1])
	
	return nodes

static func _draw_bezier_segment(features:Image, a:Vector2, b:Vector2) -> void:
	var mid:Vector2 = (a + b) * 0.5
	var direction:Vector2 = (b - a).normalized()
	var perpendicular_direction:Vector2 = Vector2(-direction.y, direction.x)
	var offset:float = rng.randf_range(-30.0, 30.0)
	var control:Vector2 = mid + perpendicular_direction * offset

	var previous:Vector2 = a
	var steps:int = int(a.distance_to(b) / 4)
	for i in range(1, steps + 1):
		var t:float = float(i) / float(steps)
		var current:Vector2 = _quadratic_bezier(a, control, b, t).round()
		_draw_line(features, previous, current)
		previous = current

static func _quadratic_bezier(p0:Vector2, p1:Vector2, p2:Vector2, t:float) -> Vector2:
	var u:float = 1.0 - t
	return (p0 * u * u) + (p1 * 2.0 * u * t) + (p2 * t * t)

static func _draw_line(features:Image, a:Vector2i, b:Vector2i) -> void:
	var x0:int = a.x
	var y0:int = a.y
	var x1:int = b.x
	var y1:int = b.y

	var dx:int = abs(x1 - x0)
	var dy:int = -abs(y1 - y0)

	var sx:int = -1
	if x0 < x1:sx = 1
	var sy:int = -1
	if y0 < y1:sy = 1

	var err:int = dx + dy

	while true:
		if x0 >= 0 and x0 < features.get_width() and y0 >= 0 and y0 < features.get_height():
			var col:Color = features.get_pixel(x0, y0)
			features.set_pixel(x0, y0, Color(1.0, col.g, col.b, 0)) # road in red

		if x0 == x1 and y0 == y1:break

		var e2:int = err << 1  # 2*err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

## Disjoint-set find with path compression
static func _dsu_find(parent:Array, x:int) -> int:
	var root:int = x
	while parent[root] != root:
		root = parent[root]
	## Path compress
	var curr:int = x
	while parent[curr] != root:
		var next_idx:int = parent[curr]
		parent[curr] = root
		curr = next_idx
	return root

## Return path length (sum of edge distances) between a and b on the MST adjacency
static func _mst_path_length(a:int, b:int, mst_adjacencies:Dictionary) -> float:
	var visited:Dictionary = {}
	var stack:Array[Array] = [[a, 0.0]]  ## [node, accumulated distance]
	while stack.size() > 0:
		var e:Array = stack.pop_back()
		var node:int = int(e[0])
		var acc:float = float(e[1])
		if node == b:
			return acc
		if visited.has(node):
			continue
		visited[node] = true
		if mst_adjacencies.has(node):
			var neighs:Array = mst_adjacencies[node]
			for n in neighs:
				var to_idx:int = int(n[0])
				var nd:float = float(n[1])
				if not visited.has(to_idx):
					stack.append([to_idx, acc + nd])
	return INF

## Compute MST then add extra edges biased on (MST path length)/(direct dist)
## Road_density controls fraction of candidate extra edges to add.
static func _compute_mst_with_extra_edges(cities:Array[Vector2i], road_density:float) -> Array[Array]:
	if cities.size() < 2: ## If not enough cities, return nothing
		return []

	## Build all pair edges as [distance, a_index, b_index]
	var edges:Array = []
	for i in range(cities.size()):
		for j in range(i + 1, cities.size()):
			var distance:float = cities[i].distance_to(cities[j])
			edges.append([distance, i, j])
	## Sort ascending by distance (Array.sort() sorts by first element)
	edges.sort()

	## DSU parent initialisation
	var parent:Array = []
	for i in range(cities.size()):
		parent.append(i) ## Each city starts on it's own (not connected)
	var mst:Array[Array] = [] ## Stores the found MST edges
	var mst_adjacencies:Dictionary = {} ## The list of adjacencies for path checking later
	var non_mst:Array = [] ## Stores edges that were discarded from the MST edges so they can be searched later for redundant paths
	## For each edge that is possible between cities, find their start and end points and locate their parent set
	for edge in edges:
		var a_index:int = int(edge[1])
		var b_index:int = int(edge[2])
		var distance:float = float(edge[0])
		var a_root_set:int = _dsu_find(parent, a_index)
		var b_root_set:int = _dsu_find(parent, b_index)
		## Because the list is sorted by path lengths, this will always be the connections using the shortest paths between all cities
		if a_root_set != b_root_set: ## If the cities are not part of the same set, they are not connected -> connect them
			parent[b_root_set] = a_root_set ## union (attach b_root_set -> a_root_set) connecting them both
			mst.append([cities[a_index], cities[b_index]])
			## Add indices a and b as keys to the mst_adjacencies dictionary
			if not mst_adjacencies.has(a_index):
				mst_adjacencies[a_index] = []
			if not mst_adjacencies.has(b_index):
				mst_adjacencies[b_index] = []
			## Add the connections between these two indices and record the distance between them
			mst_adjacencies[a_index].append([b_index, distance])
			mst_adjacencies[b_index].append([a_index, distance])
		else: ## Add the connection as a potential future redundant connection
			non_mst.append([distance, a_index, b_index])
	
	## Rank non-MST edges by their distance saving compared to the MST path
	var candidates:Array[Array] = []
	for edge in non_mst:
		var direct:float = float(edge[0])
		var a_index:int = int(edge[1])
		var b_index:int = int(edge[2])
		if direct <= 0.0:
			continue
		var path_len:float = _mst_path_length(a_index, b_index, mst_adjacencies)
		if path_len <= 0.0 or path_len >= INF:
			continue
		var stretch:float = path_len / direct
		candidates.append([stretch, a_index, b_index, direct])
	
	## Sort candidates ascending by distance saving, pick lowest distance saving entries
	if candidates.size() == 0:
		return mst
	candidates.sort()
	var num_extra:int = int(round(float(candidates.size()) * clamp(road_density, 0.0, 1.0)))
	if num_extra <= 0:
		return mst
	var extra_edges:Array[Array] = []
	var picked:int = 0
	## Iterate from highest distance saving to lowest (end of sorted array)
	for idx in range(candidates.size() - 1, -1, -1):
		if picked >= num_extra:
			break
		var c:Array = candidates[idx]
		var ai:int = int(c[1])
		var bi:int = int(c[2])
		extra_edges.append([cities[ai], cities[bi]])
		picked += 1
	
	## Return the list of Minimum Spanning Tree edges plus the redundant edges that were included
	return mst + extra_edges

## Find the nearest edge connection 
static func _nearest_edge_point(city:Vector2i, w:int, h:int) -> Vector2i:
	var cx:float = city.x
	var cy:float = city.y
	var candidates:Dictionary = {
		Vector2i(cx, 0):cy,
		Vector2i(cx, h-1):h-1-cy,
		Vector2i(0, cy):cx,
		Vector2i(w-1, cy):w-1-cx
	}
	var best_point:Vector2i = Vector2i.ZERO
	var best_distance:float = INF
	for pt in candidates.keys():
		var distance:float = candidates[pt]
		if distance < best_distance:
			best_distance = distance
			best_point = pt
	return best_point


## Generate river sources from high points and map edges
static func _find_river_sources(heightmap:Image, density:float) -> Array[Vector2i]:
	var sources:Array[Vector2i] = []
	var w:int = heightmap.get_width()
	var h:int = heightmap.get_height()
	for i in range(10):
		if rng.randf() < density:
			var edge:int = rng.randi_range(0,3)
			match edge:
				0:sources.append(Vector2i(rng.randi_range(0, w-1), 0))
				1:sources.append(Vector2i(rng.randi_range(0, w-1), h-1))
				2:sources.append(Vector2i(0, rng.randi_range(0, h-1)))
				3:sources.append(Vector2i(w-1, rng.randi_range(0, h-1)))
	return sources

## Draw the rivers going out from the start position
static func _trace_river(heightmap:Image, features:Image, start:Vector2) -> void:
	var pos:Vector2i = start
	var w:int = heightmap.get_width()
	var h:int = heightmap.get_height()
	
	while true:
		var cx:int = int(pos.x)
		var cy:int = int(pos.y)
		if cx < 0 or cy < 0 or cx >= w or cy >= h:
			break
		
		# Mark river in blue
		var c:Color = features.get_pixel(cx, cy)
		features.set_pixel(cx, cy, Color(c.r, c.g, 1.0, 0))
		
		# Find lowest neighbor
		var lowest:float = heightmap.get_pixel(cx, cy).r
		var next:Vector2i = pos
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var nx:int = cx + dx
				var ny:int = cy + dy
				if nx < 0 or ny < 0 or nx >= w or ny >= h:
					continue
				var hval:float = heightmap.get_pixel(nx, ny).r
				if hval < lowest:
					lowest = hval
					next = Vector2(nx, ny)
		
		if next == pos:
			_fill_lake(features, cx, cy)
			break
		pos = next

## Fill areas detected as lakes by the river generator
static func _fill_lake(features:Image, cx:int, cy:int) -> void:
	var to_visit:Array[Vector2] = [Vector2(cx, cy)]
	while to_visit.size() > 0:
		var p:Vector2 = to_visit.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= features.get_width() or p.y >= features.get_height():
			continue
		var c:Color = features.get_pixel(int(p.x), int(p.y))
		if c.b < 1.0:
			features.set_pixel(int(p.x), int(p.y), Color(c.r, c.g, 1.0, 0))
			for direction in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
				to_visit.append(p + direction)
