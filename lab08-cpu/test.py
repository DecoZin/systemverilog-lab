
paths1 = [
    ["/lan/cva/hsvasic40/users/test1", "60 GB"],
    ["/lan/cva/hsvasic40/users/test1/dir1", "10GB"],
    ["/lan/cva/hsvasic40/users/test1/dir2", "5GB"],
    ["/lan/cva/hsvasic40/users/test1/dir2/subdir1", "2GB"],
    ["/lan/cva/hsvasic40/users/test1/dir2/subdir2", "3GB"],
    ["/lan/cva/hsvasic40/users/test1/dir3", "15GB"],
    ["/lan/cva/hsvasic40/users/test1/dir3/subdir1", "5GB"],
    ["/lan/cva/hsvasic40/users/test1/dir3/subdir2", "10GB"],
    ["/lan/cva/hsvasic40/users/test1/dir4", "30GB"],
    ["/lan/cva/hsvasic40/users/test1/dir4/subdir1", "20GB"],
    ["/lan/cva/hsvasic40/users/test1/dir4/subdir2", "10GB"]]
paths2 = [
    ["/lan/cva/hsvasic40/users/test2", "60GB"],
    ["/lan/cva/hsvasic40/users/test2/dir4", "30GB"],
    ["/lan/cva/hsvasic40/users/test2/dir4/subdir1", "20GB"],
    ["/lan/cva/hsvasic40/users/test2/dir3", "15GB"],
    ["/lan/cva/hsvasic40/users/test2/dir1", "10GB"],
    ["/lan/cva/hsvasic40/users/test2/dir3/subdir2", "10GB"],
    ["/lan/cva/hsvasic40/users/test2/dir4/subdir2", "10GB"],
    ["/lan/cva/hsvasic40/users/test2/dir2", "5GB"],
    ["/lan/cva/hsvasic40/users/test2/dir3/subdir1", "5GB"],
    ["/lan/cva/hsvasic40/users/test2/dir2/subdir2", "3GB"],
    ["/lan/cva/hsvasic40/users/test2/dir2/subdir1", "2GB"]]

user_data = {"test1": paths1, "test2": paths2}

def parse_size(size_str: str) -> int:
    """
    Converts a size string to an integer number of bytes.

    The input string can be in the following formats:

        - A bare number (e.g. 123)
        - A number followed by "GB" (e.g. 1 TB)
        - A number followed by "GB" (e.g. 1024GB)
        - A number followed by "MB" (e.g. 1MB)
        - A number followed by "KB" (e.g. 512KB)

    Args:
        size_str (str): The size string to convert.

    Returns: 
        int: The size in bytes as an integer.
    """
    size_str = size_str.upper().strip()
    if size_str.endswith("TB"):
        return int(size_str[:-2]) * 1024**4
    elif size_str.endswith("GB"):
        return int(size_str[:-2]) * 1024**3
    elif size_str.endswith("MB"):
        return int(size_str[:-2]) * 1024**2
    elif size_str.endswith("KB"):
        return int(size_str[:-2]) * 1024
    else:
        return int(size_str)
    
def format_size(size_bytes: int) -> str:
    """
    Converts a size in bytes to a human-readable string.

    Args:
        size_bytes (int): The size in bytes.

    Returns:
        str: The size in a human-readable format (e.g. 1.5MB).
    """
    if size_bytes == 0:
        return "0B"
    units = ["B", "KB", "MB", "GB", "TB", "PB"]
    i = 0
    while size_bytes >= 1024 and i < len(units) - 1:
        size_bytes /= 1024.0
        i += 1
    return f"{size_bytes:.1f}{units[i]}"

class Node:
    def __init__(self, name, size=0):
        self.name = name
        self.size = size  # in bytes
        self.children = {}

    def add_path(self, parts: list, size: str):
        """
        Recursively adds a path and its size to the tree.

        Args:
            parts (list of str): The path split into parts.
            size (str): The size of the path as a string (e.g. "10GB").

        Returns:
            None
        """
        if not parts:
            return
        part = parts[0]
        if part not in self.children:
            self.children[part] = Node(part)
        if len(parts) == 1:
            self.children[part].size = parse_size(size)
        else:
            self.children[part].add_path(parts[1:], size)

    def compute_total_size(self) -> int:
        """
        Recursively computes the total size of this node by summing the sizes
        of all its children.

        Returns:
            int: The total size of this node in bytes.
        """
        if self.size == 0:
            self.size = sum(child.compute_total_size() for child in self.children.values())
        return self.size

    def _build_tree_lines(self, prefix="", is_last=True) -> list:
        """
        Recursively builds a list of strings representing the tree structure of this node.

        Each string is indented to show the hierarchy of the tree, and the size of each node is displayed in GB. The returned list is sorted by size in descending order.

        Args:
            prefix (str): The prefix to add to the start of each line.
            is_last (bool): Whether this node is the last child of its parent.

        Returns:
            list of str: The list of strings representing the tree structure.
        """
        connector = "└── " if is_last else "├── "
        size_str = format_size(self.size)
        line = f"{prefix}{connector if prefix else ''}{self.name} - {size_str}"
        lines = [line]
        children = sorted(self.children.values(), key=lambda c: c.size, reverse=True)
        for i, child in enumerate(children):
            last = (i == len(children) - 1)
            child_prefix = prefix + ("    " if is_last else "│   ")
            lines.extend(child._build_tree_lines(child_prefix, is_last=last))
        return lines

    def print_tree(self):
        """
        Prints the tree structure to the console, with sizes in GB.

        The tree is indented to show hierarchy, and the size of each node is displayed in GB. The nodes are sorted by size in descending order.
        """
        for line in self._build_tree_lines():
            print(line)

    def to_ascii_tree(self):
        """
        Returns a string representing the tree structure, with sizes in GB.

        The string is indented to show hierarchy, and the size of each node is displayed in GB. The nodes are sorted by size in descending order.

        Returns:
            str: The string representation of the tree structure.
        """
        return "\n".join(self._build_tree_lines())


def build_user_tree(user: str, folders: list) -> Node:
    """
    Constructs a tree structure representing a user's directory hierarchy.

    Given a user and a list of folders with their sizes, this function builds
    a tree with the user as the root node. Each folder path is split into 
    parts, and the directory structure is recursively added to the tree. 
    The size of each directory is converted to bytes and stored in the 
    corresponding node. The total size of each node is computed 
    by summing the sizes of its children.

    Args:
        user (str): The name of the user, which becomes the root node.
        folders (list of tuples): A list where each tuple contains a folder 
                                  path (str) and its size (str, e.g., "10GB").

    Returns:
        Node: The root node representing the user's directory tree.
    """

    root = Node(user)
    for path, size in folders:
        parts = path.strip("/").split("/")
        try:
            idx = parts.index(user)
            user_parts = parts[idx + 1:]  # Skip adding root as a child
            if user_parts:
                root.add_path(user_parts, size)
            else:
                root.size = parse_size(size)
        except ValueError:
            continue
    root.compute_total_size()
    return root

def build_ascii_tree_html(root_node: Node, title="Directory Tree") -> str:
    """
    Generates an HTML representation of a directory tree structure in ASCII art.

    This function converts a directory tree, represented by the root_node, into
    an ASCII art format and embeds it within an HTML template. The resulting HTML is styled with monospace font and pre-formatted text to preserve the ASCII tree structure. The HTML output includes a title for the page.

    Args:
        root_node (Node): The root of the directory tree to be converted to ASCII.
        title (str): The title to be displayed in the HTML document's title bar.

    Returns:
        str: A string containing the HTML representation of the directory tree.
    """

    tree_text = root_node.to_ascii_tree()
    html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{title}</title>
    <style>
        body {{
            font-family: monospace;
            white-space: pre;
            background-color: #f9f9f9;
            padding: 20px;
        }}
    </style>
</head>
<body>
<pre>{tree_text}</pre>
</body>
</html>"""
    return html

if __name__ == "__main__":
    user_data = {"test1": paths1, "test2": paths2}
    for user, folders in user_data.items():
        print(f"\nTree for user: {user}")
        tree = build_user_tree(user, folders)
        tree.print_tree()  # Only this
        html_output = build_ascii_tree_html(tree, title="Tree for user: test1")

        with open(f"tree_{user}.html", "w", encoding="utf-8") as f:
            f.write(html_output)
