extends Node
class_name YAMLParser
##Parser created by lowlevel-1989 NOT ME!!! https://github.com/lowlevel-1989/YAML.gd/tree/master
# Node types for YAML parsing
const NODE_DICT = 0  # Dictionary node
const NODE_LIST = 1  # Array node

# Multiline block states
const ML_NONE = 0         # No multiline block
const ML_LITERAL = 1      # Literal block (|)
const ML_FOLDED = 2       # Folded block (>)
const ML_DOUBLE_QUOTE = 3 # Double quoted string (")
const ML_SINGLE_QUOTE = 4 # Single quoted string (')

# Main parse function - converts YAML string to Godot data structures
func parse(yaml_content: String) -> Variant:
	var lines = yaml_content.split("\n", true)  # Allow empty lines
	var stack = []        # Stack for tracking indentation levels [indent, node, node_type, current_key]
	var root = null       # Root node of parsed structure
	var current = null    # Current working node
	var current_type = -1 # Type of current node (NODE_DICT or NODE_LIST)
	var last_indent = 0   # Last indent level
	
	# Multiline handling variables
	var in_multiline = ML_NONE      # Current multiline state
	var multiline_indent = 0        # Indent level of multiline block
	var multiline_key = ""          # Key for multiline value
	var multiline_content = []      # Accumulated multiline content
	var multiline_chomping = "clip" # Chomping behavior (clip, strip, keep)
	var in_quotes = false           # Inside quoted string
	var quote_char = ""             # Type of quote (" or ')
	var escape_next = false         # Next character is escaped
	
	# Store current key for dictionary contexts
	var current_key = ""
	
	# Process each line in YAML content
	for i in range(lines.size()):
		var line_str = lines[i].rstrip("\r")
		
		# Handle quoted strings spanning multiple lines
		if in_quotes:
			var line_content = ""
			for j in range(line_str.length()):
				var c = line_str[j]
				
				# Process escaped characters
				if escape_next:
					escape_next = false
					match c:
						"n": line_content += "\n"   # Newline
						"t": line_content += "\t"   # Tab
						"r": line_content += "\r"   # Carriage return
						"\\": line_content += "\\"  # Backslash
						"\"": line_content += "\""  # Double quote
						"'": line_content += "'"    # Single quote
						_: line_content += c        # Any other escaped char
					continue
				
				# Start escape sequence
				if c == "\\":
					escape_next = true
					continue
				
				# End of quoted string
				if c == quote_char:
					in_quotes = false
					multiline_content.append(line_content)
					var full_content = "\n".join(multiline_content)
					
					# Assign value to current node
					if current_type == NODE_DICT:
						current[multiline_key] = full_content
					else:
						current.append(full_content)
					
					# Reset multiline state
					in_multiline = ML_NONE
					multiline_content = []
					continue
				
				line_content += c
			
			# If still in quotes, save content and continue
			if in_quotes:
				multiline_content.append(line_content)
			continue
		
		# Handle literal (|) and folded (>) multiline blocks
		if in_multiline in [ML_LITERAL, ML_FOLDED]:
			# Check if block ended (less indentation)
			var current_indent = _get_indent_level(line_str)
			if current_indent < multiline_indent:
				# Finalize multiline block
				var full_content = _process_multiline_content(
					multiline_content, 
					in_multiline, 
					multiline_chomping
				)
				
				# Assign value to current node
				if current_type == NODE_DICT:
					current[multiline_key] = full_content
				else:
					current.append(full_content)
				
				# Reset multiline state
				in_multiline = ML_NONE
				multiline_content = []
				
				# Reprocess current line
				i -= 1
				continue
			
			# Remove block indent from multiline block lines
			var ml_line = line_str
			var block_indent = multiline_indent
			if ml_line.length() > block_indent:
				ml_line = ml_line.substr(block_indent)
			else:
				ml_line = ""
			multiline_content.append(ml_line)
			continue
		
		# Skip empty lines and comments
		var stripped_line = line_str.lstrip(" \t")
		if stripped_line.is_empty() or stripped_line[0] == "#":
			continue
		
		# Calculate current indent level
		var indent = _get_indent_level(line_str)
		var content_str = line_str.substr(indent)
		
		# Handle decreased indentation (pop stack)
		if indent < last_indent:
			# Pop stack until matching indent level
			while stack and stack.back()[0] >= indent:
				var popped = stack.pop_back()
				current = popped[1]
				current_type = popped[2]
				if current_type == NODE_DICT:
					current_key = popped[3] if popped.size() > 3 else ""
		
		# Initialize root node
		if root == null:
			if content_str.begins_with("-"):
				root = []
				current = root
				current_type = NODE_LIST
			else:
				root = {}
				current = root
				current_type = NODE_DICT
			stack.append([indent, current, current_type, current_key])
		
		# Process list items - FIXED SECTION
		if content_str.begins_with("-"):
			# Extract list item content
			var item_content = content_str.substr(1).strip_edges()
			var parts = _split_key_value(item_content)
			
			# Handle empty items (dash followed by nothing)
			if item_content.strip_edges().is_empty():
				# Create a new dictionary for the empty item
				var new_dict = {}
				
				if current_type == NODE_LIST:
					current.append(new_dict)
					# Push the list context to stack
					stack.append([indent, current, current_type, current_key])
					# Switch to the new dictionary
					current = new_dict
					current_type = NODE_DICT
					current_key = ""
				else:
					# Create a new list for the dictionary value
					var new_list = [new_dict]
					
					# Assign to current key in parent dictionary
					if stack.size() > 0:
						var parent = stack.back()[1]
						var parent_type = stack.back()[2]
						if parent_type == NODE_DICT:
							parent[current_key] = new_list
					
					# Update current node to the new list
					current = new_list
					current_type = NODE_LIST
					stack.append([indent, current, current_type, current_key])
					
					# Push the dictionary to stack
					stack.append([indent, new_dict, NODE_DICT, ""])
					current = new_dict
					current_type = NODE_DICT
					current_key = ""
			# Simple value (no colon)
			elif parts[1] == null:
				if current_type == NODE_LIST:
					current.append(_parse_value(parts[0]))
				else:
					# Create a new list for the dictionary value
					var new_list = [_parse_value(parts[0])]
					
					# Assign to current key in parent dictionary
					if stack.size() > 0:
						var parent = stack.back()[1]
						var parent_type = stack.back()[2]
						if parent_type == NODE_DICT:
							parent[current_key] = new_list
					
					# Update current node to the new list
					current = new_list
					current_type = NODE_LIST
					stack.append([indent, current, current_type, current_key])
			# Dictionary in list (has colon)
			else:
				# Dictionary in list
				var new_dict = {}
				new_dict[parts[0]] = _parse_value(parts[1])
				
				if current_type == NODE_LIST:
					current.append(new_dict)
					# Save the list context for popping later
					stack.append([indent, current, current_type, current_key])
					# Switch to the new dictionary
					current = new_dict
					current_type = NODE_DICT
					current_key = parts[0]
				else:
					# Create a new list for the dictionary
					var new_list = [new_dict]
					
					# Assign to current key in parent dictionary
					if stack.size() > 0:
						var parent = stack.back()[1]
						var parent_type = stack.back()[2]
						if parent_type == NODE_DICT:
							parent[current_key] = new_list
					
					# Update current node to the new list
					current = new_list
					current_type = NODE_LIST
					stack.append([indent, current, current_type, current_key])
					
					# Now push the dictionary for children
					stack.append([indent, new_dict, NODE_DICT, parts[0]])
					current = new_dict
					current_type = NODE_DICT
					current_key = parts[0]
				
		# Process key-value pairs
		else:
			var parts = _split_key_value(content_str)
			var key = parts[0]
			var value_str = parts[1]
			
			current_key = key  # Store current key for reference
			
			if value_str == null:
				# Look ahead: is next line more indented? If so, create dict, else assign null
				var next_indent = -1
				var is_child = false
				# Look for next non-comment line
				var j = i + 1
				while j < lines.size():
					var next_line = lines[j].rstrip("\r")
					var next_stripped = next_line.lstrip(" \t")
					if next_stripped.is_empty() or next_stripped[0] == "#":
						j += 1
						continue
					next_indent = _get_indent_level(next_line)
					if next_indent > indent:
						is_child = true
					break
				
				if is_child:
					var new_dict = {}
					if current_type == NODE_DICT:
						current[key] = new_dict
						stack.append([indent, current, current_type, current_key])
						current = new_dict
						current_type = NODE_DICT
						current_key = key
					else:
						var dict_in_list = {key: new_dict}
						current.append(dict_in_list)
						stack.append([indent, current, current_type, current_key])
						current = new_dict
						current_type = NODE_DICT
						current_key = key
				else:
					if current_type == NODE_DICT:
						current[key] = null
					else:
						var new_dict = {key: null}
						current.append(new_dict)
			else:
				# Handle special value types
				if value_str in ["|", ">", "|-", ">-", "|+", ">+"]:
					# Configure multiline state
					in_multiline = ML_LITERAL if value_str.begins_with("|") else ML_FOLDED
					multiline_indent = indent
					multiline_key = key
					multiline_content = []
					
					# Determine chomping behavior
					if value_str.ends_with("-"):
						multiline_chomping = "strip"
					elif value_str.ends_with("+"):
						multiline_chomping = "keep"
					else:
						multiline_chomping = "clip"
				elif value_str.begins_with('"') or value_str.begins_with("'"):
					# Quoted string
					in_quotes = true
					quote_char = value_str[0]
					in_multiline = ML_DOUBLE_QUOTE if quote_char == '"' else ML_SINGLE_QUOTE
					multiline_key = key
					multiline_content = []
					
					# Parse the quoted string (without trailing newline)
					var quoted_value = _parse_quoted_string(value_str)
					multiline_content.append(quoted_value)
					
					# Check if quoted string ends on same line
					if value_str.ends_with(quote_char) && !value_str.ends_with("\\" + quote_char):
						in_quotes = false
						if current_type == NODE_DICT:
							current[key] = quoted_value
						else:
							current.append(quoted_value)
						in_multiline = ML_NONE
						multiline_content = []
				else:
					# Normal value
					var value = _parse_value(value_str)
					
					if current_type == NODE_DICT:
						current[key] = value
					else:
						current.append(value)
		
		last_indent = indent
	
	# Process any remaining multiline content
	if in_multiline in [ML_LITERAL, ML_FOLDED]:
		var full_content = _process_multiline_content(
			multiline_content, 
			in_multiline, 
			multiline_chomping
		)
		
		if current_type == NODE_DICT:
			current[multiline_key] = full_content
		else:
			current.append(full_content)
	elif in_quotes:
		var full_content = "\n".join(multiline_content)
		# Strip any trailing newline for quoted strings
		full_content = full_content.rstrip("\n")
		if current_type == NODE_DICT:
			current[multiline_key] = full_content
		else:
			current.append(full_content)
	
	return root

# Process multiline content based on style and chomping
func _process_multiline_content(content: Array, style: int, chomping: String) -> String:
	# Remove leading/trailing empty lines for strip chomping
	if chomping == "strip":
		while content.size() > 0 and content[0].strip_edges().is_empty():
			content.pop_front()
		while content.size() > 0 and content[content.size() - 1].strip_edges().is_empty():
			content.pop_back()
	
	# Find minimum indent among non-empty lines
	var min_indent = 0
	var has_non_empty = false
	for line in content:
		if line.strip_edges().is_empty():
			continue
		var line_indent = _count_leading_whitespace(line)
		if not has_non_empty or line_indent < min_indent:
			min_indent = line_indent
			has_non_empty = true
	
	# Remove common indentation
	var processed_lines = []
	for line in content:
		if line.strip_edges().is_empty():
			processed_lines.append("")
			continue
		
		if line.length() > min_indent:
			# Preserve tabs in content
			processed_lines.append(line.substr(min_indent))
		else:
			processed_lines.append(line)
	
	var full_content = "\n".join(processed_lines)
	
	# Apply chomping behavior
	match chomping:
		"strip":
			# Remove all trailing newlines
			full_content = full_content.rstrip("\n")
		"keep":
			# Keep all trailing newlines
			pass
		"clip":
			# Clip to single trailing newline if content had any newlines
			if full_content.find("\n") != -1:
				full_content = full_content.rstrip("\n") + "\n"
			else:
				full_content += "\n"
	
	# Apply folding for folded style
	if style == ML_FOLDED:
		var lines = full_content.split("\n")
		var result = []
		var prev_empty = false
		
		for i in range(lines.size()):
			var line = lines[i]
			var is_empty = line.strip_edges().is_empty()
			
			if is_empty:
				result.append("")
				prev_empty = true
			else:
				if i > 0 and !prev_empty and !result.is_empty() and !result[-1].ends_with(" "):
					# Add space between consecutive non-empty lines
					result[-1] += " " + line
				else:
					result.append(line)
				prev_empty = false
		
		full_content = "\n".join(result)
	
	return full_content

# Count leading whitespace characters (only spaces)
static func _count_leading_whitespace(line: String) -> int:
	var count = 0
	for c in line:
		if c == ' ':
			count += 1
		else:
			break
	return count

# Split key-value pair, handling colons inside quotes
static func _split_key_value(line: String) -> Array:
	var in_quotes = false
	var escape = false
	var colon_pos = -1
	
	# Find first unquoted colon
	for i in range(line.length()):
		var c = line[i]
		
		if escape:
			escape = false
			continue
			
		if c == '\\':
			escape = true
			continue
			
		if c == '"' or c == "'":
			in_quotes = !in_quotes
			continue
			
		if !in_quotes and c == ':':
			colon_pos = i
			break
	
	# No colon found - return as key with null value
	if colon_pos == -1:
		return [line.strip_edges(), null]
	
	# Split key and value
	var key = line.substr(0, colon_pos).strip_edges()
	var value = line.substr(colon_pos + 1).strip_edges()
	
	# Handle empty values
	if value.is_empty():
		value = null
	
	return [key, value]

# Convert string to appropriate data type
static func _parse_value(s: String) -> Variant:
	if s == "null": return null
	if s == "true": return true
	if s == "false": return false
	if s.is_valid_int(): return s.to_int()
	if s.is_valid_float(): return s.to_float()
	
	# Handle inline arrays
	if s.begins_with("[") and s.ends_with("]"):
		var items = s.substr(1, s.length() - 2).split(",", false)
		var result = []
		for item in items:
			result.append(_parse_value(item.strip_edges()))
		return result
	
	# Handle quoted strings
	if (s.begins_with('"') and s.ends_with('"')) or (s.begins_with("'") and s.ends_with("'")):
		return _parse_quoted_string(s)
	
	return s

# Parse quoted strings with escape sequences
static func _parse_quoted_string(s: String) -> String:
	# Remove outer quotes
	var content = s
	if content.length() >= 2:
		content = content.substr(1, content.length() - 2)
	
	var result = ""
	var escape = false
	
	for i in range(content.length()):
		var c = content[i]
		
		# Process escape sequences
		if escape:
			escape = false
			match c:
				"n": result += "\n"   # Newline
				"t": result += "\t"   # Tab
				"r": result += "\r"   # Carriage return
				"\\": result += "\\"  # Backslash
				"\"": result += "\""  # Double quote
				"'": result += "'"    # Single quote
				_: result += c        # Any other escaped char
			continue
		
		# Start escape sequence
		if c == "\\":
			escape = true
			continue
		
		result += c
	
	return result

# Calculate indent level (only spaces)
static func _get_indent_level(line: String) -> int:
	var indent = 0
	for c in line:
		if c == ' ':
			indent += 1
		else:
			break
	return indent
