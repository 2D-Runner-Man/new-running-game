# game_over_screen.py
import pygame
import sys
# from running_game import game_loop

def game_over_screen(screen, font, large_font, player_name):
    """Display a Game Over screen"""

    game_over_image = pygame.image.load("images/game-over-screen.png").convert_alpha()

    game_over_text = large_font.render("Press the [esc] key to exit", True, (255, 255, 255))
    game_over_rect = game_over_image.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 20))

    restart_text = font.render("Restart", True, (255, 255, 255))
    restart_rect = restart_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 + 150))

    player_name_text = font.render("You got hit too many times " + player_name, True, (255, 255, 255))
    player_name_rect = player_name_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 + 80))

    while True:
        screen.fill((32, 32, 32))  # Black background

        # Detect mouse position
        mouse_pos = pygame.mouse.get_pos()
        is_hovered = restart_rect.collidepoint(mouse_pos)

        # Change button color when hovered
        # button_color = (39, 104, 163) # Blue Color
        button_color = (0, 166, 37) if is_hovered else (67, 127, 181)
    
        screen.blit(game_over_image, game_over_rect)
        screen.blit(game_over_text, game_over_text.get_rect(center=(screen.get_width() // 2 - 10, screen.get_height() // 2 + 10)))

        screen.blit(player_name_text, player_name_rect)

        pygame.draw.rect(screen, button_color, restart_rect.inflate(30, 10), border_radius=10)  # Button background
        screen.blit(restart_text, restart_rect)  # Draw button text

        for event in pygame.event.get():
            if event.type == pygame.QUIT:  # Handle closing window
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE: # Uses only escape key to exit
                pygame.quit()
                sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if restart_rect.collidepoint(event.pos):  # Check if clicked
                    return  # Exit function to restart the game

        pygame.display.flip()