const std = @import("std");

// Definindo a estrutura do nó
const Node = struct {
    value: i32,
    next: *Node,
};

// Função para criar um novo nó
fn createNode(allocator: std.mem.Allocator, value: i32) !*Node {
    const node = try allocator.create(Node);
    node.* = Node{
        .value = value,
        .next = node, // Inicialmente, o nó aponta para si mesmo (lista circular de um elemento)
    };
    return node;
}

// Função para inserir um valor após o último nó
fn insert(allocator: std.mem.Allocator, head: ?*Node, value: i32) !*Node {
    const new_node = try createNode(allocator, value);
    
    if (head == null) {
        return new_node; // Se a lista está vazia, retorna o novo nó como cabeça
    }

    // Encontrar o último nó (aquele que aponta para a cabeça)
    var current = head.?;
    while (current.next != head.?) {
        current = current.next;
    }

    // Inserir o novo nó após o último
    new_node.next = current.next; // Novo nó aponta para a cabeça
    current.next = new_node;      // Último nó aponta para o novo nó
    return head.?;                // Retorna a cabeça original
}

// Função para exibir a lista
fn printList(head: ?*Node) void {
    if (head == null) {
        std.debug.print("Lista vazia\n", .{});
        return;
    }

    var current = head.?;
    std.debug.print("Lista: ", .{});
    while (true) {
        std.debug.print("{} ", .{current.value});
        current = current.next;
        if (current == head) break; // Para quando voltar à cabeça
    }
    std.debug.print("\n", .{});
}

// Função para remover um valor da lista
fn remove(allocator: std.mem.Allocator, head: ?*Node, value: i32) ?*Node {
    if (head == null) return null;

    var current = head.?;
    var prev: *Node = undefined;
    var new_head = head;

    // Caso especial: lista com um único nó
    if (current.next == current and current.value == value) {
        allocator.destroy(current);
        return null;
    }

    // Encontrar o nó a ser removido e seu anterior
    while (true) {
        prev = current;
        current = current.next;
        
        if (current.value == value) {
            // Se o nó a ser removido é a cabeça
            if (current == head.?) {
                new_head = current.next;
            }
            
            prev.next = current.next;
            allocator.destroy(current);
            return if (new_head == head) head else new_head;
        }
        
        if (current == head.?) break; // Volta completa, valor não encontrado
    }
    
    return head; // Valor não encontrado
}

// Função para liberar toda a lista
fn freeList(allocator: std.mem.Allocator, head: ?*Node) void {
    if (head == null) return;

    var current = head.?;
    var next: *Node = undefined;
    
    while (true) {
        next = current.next;
        allocator.destroy(current);
        current = next;
        if (current == head) break;
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Criando a lista
    var head: ?*Node = null;
    
    // Inserindo valores
    head = try insert(allocator, head, 10);
    head = try insert(allocator, head, 20);
    head = try insert(allocator, head, 30);
    head = try insert(allocator, head, 40);

    // Exibindo a lista
    printList(head);

    // Removendo um valor
    head = remove(allocator, head, 20);
    printList(head);

    // Removendo a cabeça
    head = remove(allocator, head, 10);
    printList(head);

    // Liberando a memória
    defer freeList(allocator, head);
}
