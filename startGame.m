function startGame()
% STARTGAME - This function takes no inputs. It sets up the intro screen
% for Super Mario Bros. After user presses space bar, it launches the
% function RUNMARIO, which then starts the actual game.

%% Creating Intro Screen
% Create Intro Figure
gFig = figure('Units','Normalized','OuterPosition',[0 .1 1 .9]);
% Intialize a Key Press Function
set(gFig, 'KeyPressFcn', @startMario);
% Show Custom Controls Screen
imshow(imread('MarioControls.jpg'));
% Give User Intructions as to how to play the game
startText = text(130,165, 'Press SPACE To Play','FontSize', 25, 'Color', 'w');

%% Callback Functions
    function startMario(~,edata)
        % STARTMARIO - This callback function takes in the data from the
        % keyboard, edata, as to what key is pressed. When the space bar is
        % pressed, it will delete everything from the screen and run RUNMARIO
        switch edata.Key
            % SPACE BAR
            case 'space'
                % We will delete the current figure and the text overlay
                delete(gFig)
                delete(startText)
                % Okay, Now Let's Play the Game
                RUNMARIO
        end
    end
end
