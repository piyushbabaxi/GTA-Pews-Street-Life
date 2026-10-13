extends Node3D

var player: CharacterBody3D
var move_dir := Vector2.ZERO
var move_speed := 5.0

func _ready() -> void:
    create_world()
    create_player()
    create_mobile_controls()

func create_world() -> void:
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-45, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

    var ground := make_box(
        Vector3(0, -0.3, 0),
        Vector3(100, 0.5, 100),
        Color(0.30, 0.40, 0.28)
    )
    add_child(ground)

    var road := make_box(
        Vector3(0, 0, 0),
        Vector3(12, 0.1, 100),
        Color(0.12, 0.13, 0.15)
    )
    add_child(road)

    for i in range(-5, 6):
        var mark := make_box(
            Vector3(0, 0.07, i * 8),
            Vector3(0.18, 0.03, 3),
            Color(1.0, 0.9, 0.65)
        )
        add_child(mark)

    for side in [-1, 1]:
        for i in range(8):
            var height := 4.0 + float((i * 3) % 5)
            var building := make_box(
                Vector3(side * 14, height / 2.0, i * 10 - 35),
                Vector3(7, height, 7),
                Color(0.70, 0.59, 0.46)
            )
            add_child(building)

func make_box(pos: Vector3, dimensions: Vector3, tint: Color) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.position = pos

    var mesh := MeshInstance3D.new()
    var shape_mesh := BoxMesh.new()
    shape_mesh.size = dimensions
    mesh.mesh = shape_mesh

    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mesh.material_override = mat
    body.add_child(mesh)

    var collision := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = dimensions
    collision.shape = box_shape
    body.add_child(collision)

    return body

func create_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 1.1, 10)
    add_child(player)

    var mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.38
    capsule.height = 1.8
    mesh.mesh = capsule

    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.12, 0.16, 0.23)
    mesh.material_override = mat
    player.add_child(mesh)

    var collider := CollisionShape3D.new()
    var capsule_shape := CapsuleShape3D.new()
    capsule_shape.radius = 0.38
    capsule_shape.height = 1.8
    collider.shape = capsule_shape
    player.add_child(collider)

    var camera := Camera3D.new()
    camera.position = Vector3(0, 4, 7)
    camera.rotation_degrees = Vector3(-20, 0, 0)
    player.add_child(camera)
    camera.current = true

func create_mobile_controls() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var pad := HBoxContainer.new()
    pad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    pad.position = Vector2(20, -110)
    pad.size = Vector2(300, 90)
    layer.add_child(pad)

    add_move_button(pad, "LEFT", Vector2(-1, 0))
    add_move_button(pad, "FORWARD", Vector2(0, -1))
    add_move_button(pad, "BACK", Vector2(0, 1))
    add_move_button(pad, "RIGHT", Vector2(1, 0))

func add_move_button(parent: Control, caption: String, direction: Vector2) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(72, 75)
    button.button_down.connect(func(): move_dir = direction)
    button.button_up.connect(func():
        if move_dir == direction:
            move_dir = Vector2.ZERO
    )
    parent.add_child(button)

func _physics_process(delta: float) -> void:
    if player == null:
        return

    var direction := move_dir

    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        direction.y = -1
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        direction.y = 1
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        direction.x = -1
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        direction.x = 1

    direction = direction.normalized()
    player.velocity.x = direction.x * move_speed
    player.velocity.z = direction.y * move_speed

    if not player.is_on_floor():
        player.velocity.y -= 20.0 * delta
    else:
        player.velocity.y = -0.2

    player.move_and_slide()
