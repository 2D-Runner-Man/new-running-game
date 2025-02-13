# game_over_screen.py
import pygame
import sys
# from running_game import game_loop

def game_over_screen(screen, font, large_font):
    """Display a Game Over screen."""

    game_over_image = pygame.image.load("images/game-over-screen.png").convert_alpha()

    game_over_text = large_font.render("Press the [esc] key to exit", True, (255, 255, 255))

    restart_text = font.render("Restart", True, (255, 255, 255))

    restart_rect = restart_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 + 110))

    while True:
        screen.fill((32, 32, 32))  # Black background
     
        game_over_rect = game_over_image.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 30))
        screen.blit(game_over_image, game_over_rect)
        screen.blit(game_over_text, game_over_text.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 + 20)))

        # Detect mouse position
        mouse_pos = pygame.mouse.get_pos()
        is_hovered = restart_rect.collidepoint(mouse_pos)

        # Change button color when hovered
        button_color = (255, 50, 50) if is_hovered else (200, 0, 0)

        pygame.draw.rect(screen, button_color, restart_rect.inflate(30, 10), border_radius=10)  # Button background
        screen.blit(restart_text, restart_rect)  # Draw button text


        for event in pygame.event.get():
            if event.type == pygame.QUIT:  # Handle closing window
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                pygame.quit()
                sys.exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if restart_rect.collidepoint(event.pos):  # Check if clicked
                    return  # Exit function to restart the game

        pygame.display.flip()