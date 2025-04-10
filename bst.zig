const std = @import("std");

// Definindo a estrutura do nó da árvore
const Node = struct {
    value: i32,
    left: ?*Node,
    right: ?*Node,
};

// Função para criar um novo nó
fn createNode(allocator: std.mem.Allocator, value: i32) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .value = value,
        .left = null,
        .right = null,
    };
    return node;
}

// Função para inserir um valor na árvore
fn insert(allocator: std.mem.Allocator, root: ?*Node, value: i32) !*Node {
    if (root == null) {
        return try createNode(allocator, value);
    }

    if (value < root.?.value) {
        root.?.left = try insert(allocator, root.?.left, value);
    } else if (value > root.?.value) {
        root.?.right = try insert(allocator, root.?.right, value);
    }
    return root.?;
}

// Função para percorrer a árvore em ordem (in-order traversal)
fn inOrder(node: ?*Node) void {
    if (node) |n| {
        inOrder(n.left);
        std.debug.print("{} ", .{n.value});
        inOrder(n.right);
    }
}

// Função para liberar a memória da árvore
fn freeTree(allocator: std.mem.Allocator, node: ?*Node) void {
    if (node) |n| {
        freeTree(allocator, n.left);
        freeTree(allocator, n.right);
        allocator.destroy(n);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Criando a árvore
    var root: ?*Node = null;
    
    // Inserindo valores
    root = try insert(allocator, root, 50);
    root = try insert(allocator, root, 30);
    root = try insert(allocator, root, 70);
    root = try insert(allocator, root, 20);
    root = try insert(allocator, root, 40);
    root = try insert(allocator, root, 60);
    root = try insert(allocator, root, 80);

    // Imprimindo a árvore em ordem
    std.debug.print("Árvore em ordem: ", .{});
    inOrder(root);
    std.debug.print("\n", .{});

    // Liberando a memória
    defer freeTree(allocator, root);
}
