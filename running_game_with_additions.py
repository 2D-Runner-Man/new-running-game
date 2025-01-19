import pygame
import sys
from start_page import start_screen

# Initialize pygame
pygame.init()

# Screen dimensions
SCREEN_WIDTH, SCREEN_HEIGHT = 900, 500
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))

# Game Caption
pygame.display.set_caption("2D Running Game")

# Colors
BLACK = (32, 32, 32)
RED = (255, 0, 0)
GREEN = (0, 255, 0)

# Clock for controlling frame rate
clock = pygame.time.Clock()

# Constants
GROUND_Y = 395  # Y-coordinate of the ground line

# Player class
class Player(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height):
        super().__init__()
        self.original_image = pygame.Surface((width, height), pygame.SRCALPHA)
        self.original_image.fill(RED)
        self.image = self.original_image
        self.rect = self.image.get_rect(topleft=(x, y))
        self.x_velocity = 0
        self.y_velocity = 0
        self.jumping = True
        self.angle = 0  # Angle for rotation

    def update(self, controller):
        # Movement logic
        if controller["up"] and not self.jumping:
            self.y_velocity -= 20
            self.jumping = True

        if controller["left"]:
            self.x_velocity -= 0.5
            self.angle += 5  # Rotate counter-clockwise

        if controller["right"]:
            self.x_velocity += 0.5
            self.angle -= 5  # Rotate clockwise

        # Apply physics
        self.rect.x += self.x_velocity
        self.rect.y += self.y_velocity
        self.y_velocity += 0.8  # Gravity
        self.x_velocity *= 0.95  # Friction
        self.y_velocity *= 0.95  # Friction

        # Check ground collision
        if self.rect.y > GROUND_Y - self.rect.height:
            self.rect.y = GROUND_Y - self.rect.height
            self.y_velocity = 0
            self.jumping = False

        # Boundary wrap-around
        if self.rect.x < -self.rect.width:
            self.rect.x = SCREEN_WIDTH
        elif self.rect.x > SCREEN_WIDTH:
            self.rect.x = -self.rect.width

        # Rotate the player
        self.image = pygame.transform.rotate(self.original_image, self.angle)
        self.rect = self.image.get_rect(center=self.rect.center)

# Obstacle class
class Obstacle(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height):
        super().__init__()
        self.image = pygame.Surface((width, height))
        self.image.fill(GREEN)
        self.rect = self.image.get_rect(topleft=(x, y))

# Game loop
def game_loop():
    # Initialize player and obstacle
    player = Player(200, GROUND_Y - 50, 50, 50)
    obstacle = Obstacle(450, 316, 75, 75)

    all_sprites = pygame.sprite.Group(player)
    obstacles = pygame.sprite.Group(obstacle)

    controller = {"left": False, "right": False, "up": False}
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

        # Update player
        player.update(controller)

        # Check collision with obstacle
        if pygame.sprite.spritecollide(player, obstacles, False):
            player.rect.x = 200
            player.rect.y = GROUND_Y - 50
            player.x_velocity = 0
            player.y_velocity = 0

        # Draw ground
        pygame.draw.line(screen, (32, 40, 48), (100, GROUND_Y), (810, GROUND_Y), 10)

        # Draw all sprites
        all_sprites.draw(screen)
        obstacles.draw(screen)

        # Update display
        pygame.display.flip()

        # Cap the frame rate
        clock.tick(60)

    pygame.quit()
    sys.exit()

# Start the game
if __name__ == "__main__":
    start_screen(screen, SCREEN_WIDTH, SCREEN_HEIGHT)
    game_loop()
