import pygame
import sys
import random
from start_page import start_screen

# Initialize pygame
pygame.init()

# Screen dimensions
SCREEN_WIDTH, SCREEN_HEIGHT = 900, 500
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))

# Game Caption
pygame.display.set_caption("2D Running Game")

# Colors
WHITE = (255, 255, 255)  # White background
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
        self.angle = 0

    def update(self, controller):
        # Movement logic
        if controller["up"] and not self.jumping:
            self.y_velocity -= 20
            self.jumping = True

        if controller["left"]:
            self.x_velocity -= 0.5
            self.angle += 5

        if controller["right"]:
            self.x_velocity += 0.5
            self.angle -= 5

        # Apply physics
        self.rect.x += self.x_velocity
        self.rect.y += self.y_velocity
        self.y_velocity += 0.8  # Gravity
        self.x_velocity *= 0.95  # Friction
        self.y_velocity *= 0.95  # Friction

        # Screen wrap-around
        if self.rect.left > SCREEN_WIDTH:  # Exit screen from the right
            self.rect.right = 0  # Appear on the left
        elif self.rect.right < 0:  # Exit screen from the left
            self.rect.left = SCREEN_WIDTH  # Appear on the right

        # Check ground collision
        if self.rect.y > GROUND_Y - self.rect.height:
            self.rect.y = GROUND_Y - self.rect.height
            self.y_velocity = 0
            self.jumping = False

        # Rotate the player
        self.image = pygame.transform.rotate(self.original_image, self.angle)
        self.rect = self.image.get_rect(center=self.rect.center)

    def respawn(self):
        """Respawn the player at the center of the screen."""
        self.rect.x = SCREEN_WIDTH // 2
        self.rect.y = -self.rect.height
        self.x_velocity = 0
        self.y_velocity = 0
        self.jumping = True

# Obstacle class
class Obstacle(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.image = pygame.Surface((width, height))
        self.image.fill(GREEN)
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self, *args):
        """Move the obstacle to the left and remove it if off-screen."""
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()

# Game loop
def game_loop():
    # Initialize player
    player = Player(200, GROUND_Y - 50, 50, 50)
    all_sprites = pygame.sprite.Group(player)
    obstacles = pygame.sprite.Group()

    controller = {"left": False, "right": False, "up": False}
    running = True

    # Timer for spawning obstacles
    obstacle_timer = 0
    spawn_interval = 90  # Spawn new obstacles every 90 frames

    while running:
        screen.fill(WHITE) # Clear screen

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
                elif event.key == pygame.K_ESCAPE and key_state:
                    running = False

        # Update player and obstacles
        all_sprites.update(controller)

        # Spawn obstacles
        obstacle_timer += 1
        if obstacle_timer >= spawn_interval:
            obstacle_timer = 0
            obstacle_x = SCREEN_WIDTH + random.randint(0, 200)
            obstacle_y = GROUND_Y - 75  # Place obstacle on the ground
            obstacle = Obstacle(obstacle_x, obstacle_y, 75, 75, speed=5)
            all_sprites.add(obstacle)
            obstacles.add(obstacle)

        # Check collision with obstacles
        if pygame.sprite.spritecollide(player, obstacles, False):
            player.respawn()  # Respawn player when colliding with an obstacle

        # Draw ground
        pygame.draw.line(screen, (32, 40, 48), (0, GROUND_Y), (SCREEN_WIDTH, GROUND_Y), 10)

        # Draw all sprites
        all_sprites.draw(screen)

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
