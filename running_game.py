import pygame
import sys
import random
# Importing from folders
from screens.start_screen import start_screen
from screens.game_over_screen import game_over_screen
from screens.name_input_screen import name_input_screen

# Initialize pygame
pygame.init()

# Screen setup
SCREEN_WIDTH, SCREEN_HEIGHT = 900, 500
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("2D Running Game")

# Colors and constants
WHITE, BLACK, RED, GREEN = (255, 255, 255), (32, 32, 32), (255, 0, 0), (0, 255, 0)
GROUND_Y, clock = 395, pygame.time.Clock()

# Fonts
font = pygame.font.Font(None, 36)
large_font = pygame.font.Font(None, 60)

class Player(pygame.sprite.Sprite):
    """The main player class with running and jumping animations."""
    def __init__(self, x, y, width, height, name):
        super().__init__()
        
        # Load running animation frames
        self.frames = [pygame.image.load(f'running-game-animations/running/frame-{i}.png').convert_alpha() for i in range(1, 7)]
        self.frames = [pygame.transform.scale(frame, (width, height + 30)) for frame in self.frames]

        # Load jump animation frames
        self.jump_up_frame = pygame.image.load("running-game-animations/jump/jump-up.png").convert_alpha()
        self.jump_fall_frame = pygame.image.load("running-game-animations/jump/jump-fall.png").convert_alpha()
        self.jump_up_frame = pygame.transform.scale(self.jump_up_frame, (width + 5, height + 30))
        self.jump_fall_frame = pygame.transform.scale(self.jump_fall_frame, (width + 5, height + 30))

        # Load life icon
        self.life_icon = pygame.image.load("running-game-animations/lives/lives.png").convert_alpha()
        self.life_icon = pygame.transform.scale(self.life_icon, (30, 30))  # Adjust size

        # Initial sprite setup
        self.current_frame = 0
        self.image = self.frames[self.current_frame]
        self.rect = self.image.get_rect(topleft=(x, y))

        # Movement properties
        self.x_velocity, self.y_velocity = 0, 0
        self.jumping = False
        self.facing_right = True  # Track movement direction
        self.name = name
        self.lives = 5 # Player live amount

        # Animation properties
        self.animation_speed = 5
        self.animation_counter = 0

    def update(self, controller):
        """Update player movement and animations."""
        if controller["up"] and not self.jumping:
            self.y_velocity = -18
            self.jumping = True

        if controller["left"]:
            self.x_velocity = -3
            self.facing_right = False  # Moving left
        elif controller["right"]:
            self.x_velocity = 3
            self.facing_right = True  # Moving right

        # Apply movement and gravity
        self.rect.x += self.x_velocity
        self.rect.y += self.y_velocity
        self.y_velocity += 0.8  # Gravity
        self.x_velocity *= 0.95  # Slow horizontal movement

        # Check if landed
        if self.rect.bottom > GROUND_Y:
            self.rect.bottom = GROUND_Y
            self.jumping = False
            self.y_velocity = 0

        # Animate player sprite
        self.animate()

    def animate(self):
        """Handle animation transitions for running and jumping."""
        if self.jumping:
            # Use jump animations and flip if moving left
            self.image = self.jump_up_frame if self.y_velocity < 0 else self.jump_fall_frame
            if not self.facing_right:
                self.image = pygame.transform.flip(self.image, True, False)
        else:
            # Running animation when on the ground
            self.animation_counter += 1
            if self.animation_counter >= self.animation_speed:
                self.animation_counter = 0
                self.current_frame = (self.current_frame + 1) % len(self.frames)
                self.image = pygame.transform.scale(self.frames[self.current_frame], self.rect.size)

                # Flip image if moving left
                if not self.facing_right:
                    self.image = pygame.transform.flip(self.image, True, False)


    def respawn(self):
        self.rect.x, self.rect.y, self.x_velocity, self.y_velocity, self.jumping = 50, -50, 0, 0, True  # Spawn at the left

    def draw(self, screen):
        """Draw the player, their name, and life icons in the top-right corner."""
        screen.blit(self.image, self.rect.topleft)

        # Draw player name
        name_surface = font.render(self.name, True, BLACK)
        screen.blit(name_surface, name_surface.get_rect(center=(self.rect.centerx, self.rect.top - 10)))

class Coin(pygame.sprite.Sprite):
    """The coin class."""
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.image = pygame.image.load('images/coin.png').convert_alpha()
        self.image = pygame.transform.scale(self.image, (width, height))
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()

class Obstacle(pygame.sprite.Sprite):
    """The obstacle class."""
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.image = pygame.image.load('images/rock-obstacle.png').convert_alpha()
        self.image = pygame.transform.scale(self.image, (width, height))
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()


def game_loop(player_name):
    """The main game loop."""
    mountain_bg = pygame.image.load("images/mountains.png").convert()
    mountain_bg = pygame.transform.scale(mountain_bg, (SCREEN_WIDTH, SCREEN_HEIGHT))
    bg_x1, bg_x2 = 0, SCREEN_WIDTH  # Positions for two background images to create a seamless loop

    player = Player(50, GROUND_Y - 50, 50, 50, name=player_name)
    all_sprites = pygame.sprite.Group(player)
    obstacles = pygame.sprite.Group()
    coins = pygame.sprite.Group()
    controller, obstacle_timer, spawn_interval, score, respawn_timer = {"left": False, "right": False, "up": False}, 0, 90, 0, 0

    while player.lives > 0:
        screen.fill(WHITE)
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
        # Scroll the background
        bg_x1 -= 2  # Adjust the speed of the scrolling
        bg_x2 -= 2
        if bg_x1 <= -SCREEN_WIDTH:
            bg_x1 = SCREEN_WIDTH
        if bg_x2 <= -SCREEN_WIDTH:
            bg_x2 = SCREEN_WIDTH

        # Draw the background
        screen.blit(mountain_bg, (bg_x1, 0))
        screen.blit(mountain_bg, (bg_x2, 0))

        # Update Sprites
        all_sprites.update(controller)
        obstacles.update()
        coins.update()

        if respawn_timer == 0:
            obstacle_timer += 1
            if obstacle_timer >= spawn_interval:
                obstacle_timer = 0
                obstacle_x = SCREEN_WIDTH + random.randint(0, 200)
                obstacle_y = GROUND_Y - 75
                coin_y = GROUND_Y - 175
                obstacles.add(Obstacle(obstacle_x, obstacle_y, 75, 75, speed=5))
                coins.add(Coin(obstacle_x, coin_y, 50, 50, speed=5))


        if pygame.sprite.spritecollide(player, obstacles, False):
            player.respawn()
            player.lives -= 1
            respawn_timer = 60  # 1 second delay before spawning obstacles

        if pygame.sprite.spritecollide(player, coins, True):
            score += 1

        if respawn_timer > 0:
            respawn_timer -= 1

        # Draws everything
        pygame.draw.line(screen, BLACK, (0, GROUND_Y), (SCREEN_WIDTH, GROUND_Y), 10)
        all_sprites.draw(screen)
        player.draw(screen)
        obstacles.draw(screen)
        coins.draw(screen)
        
        # Display Lives in the Top Left Corner
        lives_text = font.render("Lives:", True, WHITE)
        pygame.draw.rect(screen, BLACK, (5, 5, 230, 35), border_radius=5) # Background for lives
        screen.blit(lives_text, (10, 10))  # Position "Lives:" text 

        # Draw life icons next to the text
        start_x = 80  # Adjust spacing
        for _ in range(player.lives):
            screen.blit(player.life_icon, (start_x, 7))
            start_x += 30  # Space out the icons
        screen.blit(font.render(f"Score: {score}", True, BLACK), (10, 40))
        pygame.display.flip()

        clock.tick(60) # Cap the frame rate

    game_over_screen(screen, font, large_font)

# Main game flow
start_screen(screen, font, large_font)
player_name = name_input_screen(screen, font)
if player_name:  # Only proceed if a valid name is entered
    game_loop(player_name)
