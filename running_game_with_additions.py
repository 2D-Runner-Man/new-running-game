import pygame
import sys
import random

# Initialize pygame
pygame.init()

# Screen dimensions
SCREEN_WIDTH, SCREEN_HEIGHT = 900, 500
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("2D Running Game")

# Colors
WHITE = (255, 255, 255)
BLACK = (32, 32, 32)
RED = (255, 0, 0)
GREEN = (0, 255, 0)

# Clock for controlling frame rate
clock = pygame.time.Clock()

# Constants
GROUND_Y = 395  # Y-coordinate of the ground line

# Initialize font
pygame.font.init()
font = pygame.font.Font(None, 36)  # Default font with size 36


# Start screen
def start_screen(screen, screen_width, screen_height):
    """Displays the start screen."""
    font = pygame.font.Font(None, 60)
    title_text = font.render("2D Running Game", True, WHITE)
    title_rect = title_text.get_rect(center=(screen_width // 2, screen_height // 2 - 50))
    start_text = font.render("Press any key to start", True, WHITE)
    start_rect = start_text.get_rect(center=(screen_width // 2, screen_height // 2 + 50))

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                running = False

        # Clear the screen
        screen.fill(BLACK)

        # Draw text
        screen.blit(title_text, title_rect)
        screen.blit(start_text, start_rect)

        # Update the display
        pygame.display.flip()


# Name input screen
def name_input_screen():
    """Display the name input screen."""
    input_box = pygame.Rect(SCREEN_WIDTH // 2 - 150, SCREEN_HEIGHT // 2 - 25, 300, 50)
    color_active = pygame.Color('dodgerblue')
    color_inactive = pygame.Color('lightskyblue')
    color = color_inactive
    active = False
    text = ""
    running = True

    while running:
        screen.fill(WHITE)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

            if event.type == pygame.MOUSEBUTTONDOWN:
                if input_box.collidepoint(event.pos):
                    active = not active
                else:
                    active = False
                color = color_active if active else color_inactive

            if event.type == pygame.KEYDOWN:
                if active:
                    if event.key == pygame.K_RETURN:
                        return text  # Return the entered name
                    elif event.key == pygame.K_BACKSPACE:
                        text = text[:-1]  # Remove the last character
                    else:
                        text += event.unicode  # Add the entered character

        # Render the input box and text
        pygame.draw.rect(screen, color, input_box, 2)
        text_surface = font.render(text, True, BLACK)
        screen.blit(text_surface, (input_box.x + 10, input_box.y + 10))
        input_box.w = max(300, text_surface.get_width() + 20)

        # Display instructions
        instruction_surface = font.render("Enter your name and press Enter:", True, BLACK)
        screen.blit(instruction_surface, (SCREEN_WIDTH // 2 - 200, SCREEN_HEIGHT // 2 - 100))

        pygame.display.flip()
        clock.tick(30)


# Player class
class Player(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height, name="Player"):
        super().__init__()
        self.original_image = pygame.Surface((width, height), pygame.SRCALPHA)
        self.original_image.fill(RED)
        self.image = self.original_image
        self.rect = self.image.get_rect(topleft=(x, y))
        self.x_velocity = 0
        self.y_velocity = 0
        self.jumping = True
        self.angle = 0
        self.name = name

    def update(self, controller):
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
        if self.rect.left > SCREEN_WIDTH:
            self.rect.right = 0
        elif self.rect.right < 0:
            self.rect.left = SCREEN_WIDTH

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

    def draw(self, screen):
        """Draw the player and their name."""
        screen.blit(self.image, self.rect.topleft)
        name_surface = font.render(self.name, True, BLACK)
        name_rect = name_surface.get_rect(center=(self.rect.centerx, self.rect.top - 10))
        screen.blit(name_surface, name_rect)


class Obstacle(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.image = pygame.Surface((width, height))
        self.image.fill(GREEN)
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self, *args):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()


def game_loop(player_name):
    player = Player(200, GROUND_Y - 50, 50, 50, name=player_name)
    all_sprites = pygame.sprite.Group(player)
    obstacles = pygame.sprite.Group()

    controller = {"left": False, "right": False, "up": False}
    running = True
    obstacle_timer = 0
    spawn_interval = 90

    while running:
        screen.fill(WHITE)

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

        all_sprites.update(controller)

        obstacle_timer += 1
        if obstacle_timer >= spawn_interval:
            obstacle_timer = 0
            obstacle_x = SCREEN_WIDTH + random.randint(0, 200)
            obstacle_y = GROUND_Y - 75
            obstacle = Obstacle(obstacle_x, obstacle_y, 75, 75, speed=5)
            all_sprites.add(obstacle)
            obstacles.add(obstacle)

        if pygame.sprite.spritecollide(player, obstacles, False):
            player.respawn()

        pygame.draw.line(screen, BLACK, (0, GROUND_Y), (SCREEN_WIDTH, GROUND_Y), 10)
        player.draw(screen)
        obstacles.draw(screen)

        pygame.display.flip()
        clock.tick(60)

    pygame.quit()
    sys.exit()


if __name__ == "__main__":
    start_screen(screen, SCREEN_WIDTH, SCREEN_HEIGHT)  # First start screen
    player_name = name_input_screen()  # Then name input screen
    game_loop(player_name)  # Start the game
