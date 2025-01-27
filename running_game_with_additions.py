import pygame
import sys
import random

# Initialize pygame
pygame.init()

# Screen setup
SCREEN_WIDTH, SCREEN_HEIGHT = 900, 500
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("2D Running Game")

# Colors and constants
WHITE, BLACK, RED, GREEN, BLUE = (255, 255, 255), (32, 32, 32), (255, 0, 0), (0, 255, 0), (0, 0, 255)
GROUND_Y, clock = 395, pygame.time.Clock()

# Fonts
font = pygame.font.Font(None, 36)
large_font = pygame.font.Font(None, 60)


def start_screen():
    """Show the initial start screen."""
    title_text = large_font.render("2D Running Game", True, WHITE)
    start_text = large_font.render("Press any key to start", True, WHITE)
    while True:
        screen.fill(BLACK)
        screen.blit(title_text, title_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 - 50)))
        screen.blit(start_text, start_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 + 50)))
        pygame.display.flip()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                return  # Exit start screen


def name_input_screen():
    """Ask the player to input their name."""
    input_box = pygame.Rect(SCREEN_WIDTH // 2 - 150, SCREEN_HEIGHT // 2 - 25, 300, 50)
    active, color, text = False, pygame.Color('lightskyblue'), ""
    while True:
        screen.fill(WHITE)
        instruction_text = font.render("Enter your name and press Enter:", True, BLACK)
        screen.blit(instruction_text, (SCREEN_WIDTH // 2 - 200, SCREEN_HEIGHT // 2 - 100))
        pygame.draw.rect(screen, color, input_box, 2)
        screen.blit(font.render(text, True, BLACK), (input_box.x + 10, input_box.y + 10))
        pygame.display.flip()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                active = input_box.collidepoint(event.pos)
                color = pygame.Color('dodgerblue') if active else pygame.Color('lightskyblue')
            if event.type == pygame.KEYDOWN and active:
                if event.key == pygame.K_RETURN:
                    return text
                elif event.key == pygame.K_BACKSPACE:
                    text = text[:-1]
                else:
                    text += event.unicode


class Player(pygame.sprite.Sprite):
    """The main player class."""
    def __init__(self, x, y, width, height, name):
        super().__init__()
        self.original_image = pygame.Surface((width, height), pygame.SRCALPHA)
        self.original_image.fill(RED)
        self.image = self.original_image
        self.rect = self.image.get_rect(topleft=(x, y))
        self.x_velocity, self.y_velocity, self.jumping, self.angle, self.name = 0, 0, True, 0, name
        self.lives = 3  # Player starts with 3 lives

    def update(self, controller):
        if controller["up"] and not self.jumping:
            self.y_velocity, self.jumping = -20, True
        if controller["left"]:
            self.x_velocity, self.angle = self.x_velocity - 0.5, self.angle + 5
        if controller["right"]:
            self.x_velocity, self.angle = self.x_velocity + 0.5, self.angle - 5
        self.rect.x += self.x_velocity
        self.rect.y += self.y_velocity
        self.y_velocity, self.x_velocity = self.y_velocity + 0.8, self.x_velocity * 0.95
        if self.rect.bottom > GROUND_Y:
            self.rect.bottom, self.jumping, self.y_velocity = GROUND_Y, False, 0
        if self.rect.left > SCREEN_WIDTH:
            self.rect.right = 0
        elif self.rect.right < 0:
            self.rect.left = SCREEN_WIDTH
        self.image = pygame.transform.rotate(self.original_image, self.angle)
        self.rect = self.image.get_rect(center=self.rect.center)

    def respawn(self):
        """Respawn the player at the center of the screen."""
        self.rect.x, self.rect.y, self.x_velocity, self.y_velocity, self.jumping = SCREEN_WIDTH // 2, -50, 0, 0, True

    def draw(self, screen):
        """Draw the player and their name."""
        screen.blit(self.image, self.rect.topleft)
        name_surface = font.render(self.name, True, BLACK)
        screen.blit(name_surface, name_surface.get_rect(center=(self.rect.centerx, self.rect.top - 10)))


class Obstacle(pygame.sprite.Sprite):
    """The obstacle class."""
    def __init__(self, x, y, width, height, speed, color):
        super().__init__()
        self.image = pygame.Surface((width, height))
        self.image.fill(color)
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()


def game_over_screen():
    """Display a Game Over screen."""
    game_over_text = large_font.render("Game Over", True, RED)
    exit_text = font.render("Press any key to exit", True, WHITE)
    while True:
        screen.fill(BLACK)
        screen.blit(game_over_text, game_over_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 - 50)))
        screen.blit(exit_text, exit_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 + 50)))
        pygame.display.flip()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                pygame.quit()
                sys.exit()


def game_loop(player_name):
    """The main game loop."""
    player = Player(200, GROUND_Y - 50, 50, 50, name=player_name)
    all_sprites = pygame.sprite.Group(player)
    obstacles = pygame.sprite.Group()
    floating_blocks = pygame.sprite.Group()
    controller, obstacle_timer, spawn_interval, score = {"left": False, "right": False, "up": False}, 0, 90, 0

    while player.lives > 0:  # Continue the game until lives run out
        screen.fill(WHITE)

        # Event Handling
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type in (pygame.KEYDOWN, pygame.KEYUP):
                key_state = event.type == pygame.KEYDOWN
                if event.key == pygame.K_LEFT:
                    controller["left"] = key_state
                elif event.key == pygame.K_RIGHT:
                    controller["right"] = key_state
                elif event.key == pygame.K_UP:
                    controller["up"] = key_state
                elif event.key == pygame.K_ESCAPE and key_state:
                    return

        # Update Sprites
        all_sprites.update(controller)
        obstacles.update()
        floating_blocks.update()

        # Spawn Obstacles and Floating Blocks
        obstacle_timer += 1
        if obstacle_timer >= spawn_interval:
            obstacle_timer = 0
            obstacle_x = SCREEN_WIDTH + random.randint(0, 200)
            obstacle_y = GROUND_Y - 75
            floating_y = GROUND_Y - 175  # Floating block above the ground
            obstacle = Obstacle(obstacle_x, obstacle_y, 75, 75, speed=5, color=GREEN)
            floating_block = Obstacle(obstacle_x, floating_y, 50, 50, speed=5, color=BLUE)
            obstacles.add(obstacle)
            floating_blocks.add(floating_block)

        # Check Collisions
        if pygame.sprite.spritecollide(player, obstacles, False):  # Collide with ground obstacles
            player.respawn()
            player.lives -= 1  # Reduce a life on collision
        if pygame.sprite.spritecollide(player, floating_blocks, True):  # Remove floating block on collision
            score += 1  # Increase score

        # Draw Everything
        pygame.draw.line(screen, BLACK, (0, GROUND_Y), (SCREEN_WIDTH, GROUND_Y), 10)
        player.draw(screen)
        obstacles.draw(screen)
        floating_blocks.draw(screen)

        # Display Score and Lives
        score_text = font.render(f"Score: {score}", True, BLACK)
        lives_text = font.render(f"Lives: {player.lives}", True, RED)
        screen.blit(score_text, (10, 10))
        screen.blit(lives_text, (10, 50))

        pygame.display.flip()
        clock.tick(60)

    game_over_screen()  # Show Game Over screen when lives are lost


if __name__ == "__main__":
    start_screen()
    player_name = name_input_screen()
    game_loop(player_name)
