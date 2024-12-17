import pygame
import sys

# Initialize pygame
pygame.init()

# Screen dimensions
SCREEN_WIDTH, SCREEN_HEIGHT = 900, 500
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Game Conversion")

# Colors
BLACK = (32, 32, 32)
RED = (255, 0, 0)
GREEN = (0, 255, 0)

# Clock for controlling frame rate
clock = pygame.time.Clock()

# Rectangle (player) and obstacle attributes
rectangle = {
    "x": 200,
    "y": 0,
    "width": 50,
    "height": 50,
    "x_velocity": 0,
    "y_velocity": 0,
    "jumping": True
}

obstacle = {
    "x": 450,
    "y": 316,
    "width": 75,
    "height": 75
}

# Controller object to track key presses
controller = {
    "left": False,
    "right": False,
    "up": False
}

# Reset function for the player
def reset():
    rectangle["x"] = 200
    rectangle["y"] = 0
    rectangle["x_velocity"] = 0
    rectangle["y_velocity"] = 0

# Game loop
def game_loop():
    global controller
    running = True

    while running:
        screen.fill(BLACK)  # Clear screen

        # Handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            if event.type in (pygame.KEYDOWN, pygame.KEYUP):
                key_state = event.type == pygame.KEYDOWN

                if event.key == pygame.K_LEFT:
                    controller["left"] = key_state
                elif event.key == pygame.K_RIGHT:
                    controller["right"] = key_state
                elif event.key == pygame.K_UP:
                    controller["up"] = key_state

        # Update rectangle (player) movement
        if controller["up"] and not rectangle["jumping"]:
            rectangle["y_velocity"] -= 20
            rectangle["jumping"] = True

        if controller["left"]:
            rectangle["x_velocity"] -= 0.5

        if controller["right"]:
            rectangle["x_velocity"] += 0.5

        # Apply physics
        rectangle["x"] += rectangle["x_velocity"]
        rectangle["y"] += rectangle["y_velocity"]
        rectangle["y_velocity"] += 0.8  # Gravity
        rectangle["x_velocity"] *= 0.95  # Friction
        rectangle["y_velocity"] *= 0.95  # Friction

        # Check boundaries and collisions
        if rectangle["y"] > SCREEN_HEIGHT - rectangle["height"] - 10:  # Ground collision
            rectangle["y"] = SCREEN_HEIGHT - rectangle["height"] - 10
            rectangle["y_velocity"] = 0
            rectangle["jumping"] = False

        if rectangle["x"] < -rectangle["width"]:  # Left boundary
            rectangle["x"] = SCREEN_WIDTH
        elif rectangle["x"] > SCREEN_WIDTH:  # Right boundary
            rectangle["x"] = -rectangle["width"]

        # Obstacle collision
        if (
            rectangle["x"] < obstacle["x"] + obstacle["width"] and
            rectangle["x"] + rectangle["width"] > obstacle["x"] and
            rectangle["y"] < obstacle["y"] + obstacle["height"] and
            rectangle["y"] + rectangle["height"] > obstacle["y"]
        ):
            reset()

        # Draw ground
        pygame.draw.line(screen, (32, 40, 48), (100, 395), (810, 395), 10)

        # Draw rectangle (player)
        pygame.draw.rect(
            screen,
            RED,
            pygame.Rect(rectangle["x"], rectangle["y"], rectangle["width"], rectangle["height"])
        )

        # Draw obstacle
        pygame.draw.rect(
            screen,
            GREEN,
            pygame.Rect(obstacle["x"], obstacle["y"], obstacle["width"], obstacle["height"])
        )

        # Update display
        pygame.display.flip()

        # Cap the frame rate
        clock.tick(60)

    pygame.quit()
    sys.exit()

# Start the game
if __name__ == "__main__":
    game_loop()
