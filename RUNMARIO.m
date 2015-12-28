%  _____ ___ ___ ___ ___ ___ ___ ___   __  __   _   ___ ___ ___
% |_   _| __| _ \ _ \_ _| __|_ _/ __| |  \/  | /_\ | _ \_ _/ _ \
%   | | | _||   /   /| || _| | | (__  | |\/| |/ _ \|   /| | (_) |
%   |_| |___|_|_\_|_\___|_| |___\___| |_|  |_/_/ \_\_|_\___\___/
%                      ___ ___  ___  ___
%                     | _ ) _ \/ _ \/ __|
%                     | _ \   / (_) \__ \_
%                     |___/_|_\\___/|___(_)

% A MATLAB game by Varun Jain and Patrick Zerbe (2015)
% Super Mario Bros. was first created by Nintendo
% Images and sounds are from the original game resources.
% Terrific Mario Bros. was created for educational purposes
% No Goombas were hurt in the making of this game

function RUNMARIO()
% Close anything if open
close all

%% Game Constants
dt = 0.001; % Timestep of the simulation

%% Loading Sprites and Background
if exist('Mario.mat','file')
    Mario.ImData = load('Mario.mat');
else
    error('runMario(): Mario.mat not found.');
end
if exist('Enemies.mat','file')
    Enemies.ImData = load('Enemies.mat');
else
    error('runMario(): Enemies.mat not found.');
end

%% Initialize enemies
goom = cell(1,17);
GoomActivate(1:17) = false;
runTime = 0; % run animation control timer
enemyTime = 0; % enemy animation controltimer
n = 1; % enemy spawn count
% Vectors of Spawn Distances and Starting Locations of Goombas
GoomSpawnDist = [200, 450, 600, 601, 1100, 1101, 1375, 1376, 1600, 1601,...
    1810, 1811, 1812, 1813, 2640, 2641,NaN];
GoomSpawnLoc1 = [320, 705, 850, 868, 1280, 1310, 1580, 1598, 1840, 1858,...
    1984, 2002, 2064, 2062, 2770, 2788];
GoomSpawnLoc2 = GoomSpawnLoc1 + 16;


%% Creating Base Figure Window and Background
hFig = figure('Units','Normalized','OuterPosition',[0 .1 1 .9]);
hold on
% Loading background maps and transparency for Collision Detection
map.main = imread('Map1-1_Background_NoBricks.png'); % main map
[mapClearData,~,amapClearData] = imread('Map1-1_Background_OnlyBricksAndFloor.png'); % walls map
% Plotting Maps
imshow(map.main,'InitialMagnification','fit')
imshow(mapClearData,'InitialMagnification','fit')
% Initial Position of Axis Frames
Axes.Limits = [0 300 0 240];
Axes.Center = (Axes.Limits(1)+Axes.Limits(2))/2;
axis(Axes.Limits);
hold on

%% Plotting Mario
m = image([100 120],[173 208],Mario.ImData.BStand,'AlphaData',Mario.ImData.ABst);
Mario.x.Pos = m.XData;
Mario.y.Pos = m.YData;

%% Main Figure to Update Screen and Mario
set(hFig, 'KeyPressFcn', @moveMario,'KeyReleaseFcn', @stopMario);

%% Mario Constants
posVel = 1000;
negVel = -1000;
Mario.x.Vel = 0;
Mario.y.Vel = 0;
Mario.x.TermVel = 1000;
Mario.x.Acc = 0;
Mario.y.Acc = 0;
Mario.y.Acc = 240000;
JumpTimer = 0;

%% Boolean Initializatiion
quitInd = false;
Mario.x.SlowD = false;
Mario.x.SlowA = false;
Mario.PosDir = true;
Mario.NegDir = false;
JumpControl = false;
JumpKeyStatus = false;
JumpStatus = false;
Mario.isFalling = false;
beatTheGame = false;
Mario.somethingAbove = false;

%% Game Music
[Y,Fs] = audioread('MarioMusic.wav');
Mario.Music = audioplayer(Y,Fs);
play(Mario.Music)

%% Main Game Loop
while ~quitInd
    
    % Setting Y Positions and Defining Falling by Freefall
    if Mario.isFalling
        %If falling, let Mario abide by freefall physics
        Mario.y.Vel = Mario.y.Vel + Mario.y.Acc*dt;
        Mario.y.Pos = Mario.y.Pos + Mario.y.Vel*dt;
        % If he is under the map, and if he is at a hole location interval
        % let him fall by freefall phsyics, otherwise bring him back to
        % where he should be, which is on the ground (for glitches)
    elseif Mario.y.Pos(2) > 208
        % If Mario's x position is in between these locations he should go
        % below the map
        if ((Mario.x.Center >= 1105 && Mario.x.Center <= 1147) ||...
                (Mario.x.Center >= 1370 && Mario.x.Center <= 1430) ||...
                (Mario.x.Center >= 2444 && Mario.x.Center <= 2485))
            Mario.y.Vel = Mario.y.Vel + Mario.y.Acc*dt;
            Mario.y.Pos = Mario.y.Pos + Mario.y.Vel*dt;
        else
            % Otherwise, he should be put back at the ground
            Mario.y.Pos = [173 208];
        end
    end
    
    % If he is too close to the ceiling, stop him and bounce him down by
    % giving him a negative y velocity
    if ((Mario.y.Pos(1) < 2) || (Mario.y.Pos(2) < 2))
        Mario.y.Pos = [3 3+35];
        Mario.y.Vel = 50;
    end
    
    % If something is above him, stop him and bounce him down
    if Mario.somethingAbove
        Mario.y.Pos = Mario.y.Pos + 5;
        Mario.y.Vel = 50;
    end
    
    % If he falls below the map a certain distance, Mario Dies
    if Mario.y.Pos(2) > 275
        MarioIsDead
    end
    
    % Jumping
    if JumpKeyStatus
        %JumpTimer starts once 'k' is pressed. While the time the key is
        %held down is below a certain number, JumpControl is true. Once
        %that number is exceeded, JumpControl is false. Only while
        %JumpControl is true will the velocity be held constant.
        if ~Mario.isFalling
            tic
            if JumpTimer < .00001
                JumpControl = true;
                
            else
                JumpControl = false;
            end
            
            if JumpControl
                Mario.y.Pos = Mario.y.Pos - 1;
                Mario.y.Vel = -7000;
                
            end
            JumpTimer = JumpTimer + toc;
        end
    else    %when 'k' is let go, reset the timer
        JumpTimer = 0;
    end
    
    % Collision Detection
    % Ground Detection
    % Check the row below Mario of the transparent data of the hard wall
    % background to see if there is nothing below him. If there is nothing
    % then Mario is falling! We need to define it for both directions
    % because the x positions are flipped for when Mario is facing left
    if Mario.PosDir
        if all(amapClearData(floor(Mario.y.Pos(2))+1,floor(Mario.x.Pos(1)+10):floor(Mario.x.Pos(2))-10)) == 0 && ~JumpStatus
            Mario.isFalling = true;
        else
            Mario.isFalling = false;
        end
    elseif Mario.NegDir
        if all(amapClearData(floor(Mario.y.Pos(2))+1,floor(Mario.x.Pos(2)+10):floor(Mario.x.Pos(1))-10)) == 0 && ~JumpStatus
            Mario.isFalling = true;
        else
            Mario.isFalling = false;
        end
    end
    
    
    % Horizontal Collision Detection
    % Check the columns to the left and right of Mario in the transparent
    % data of the hard wall background and if there is anything nonzero
    % then something is to the left or right of Mario
    if Mario.PosDir
        if any(amapClearData(floor(Mario.y.Pos(1))+1:floor(Mario.y.Pos(2))-1,floor(Mario.x.Pos(2))+1)) ~= 0
            Mario.somethingRight = true;
        elseif any(amapClearData(floor(Mario.y.Pos(1))+1:floor(Mario.y.Pos(2))-1,ceil(Mario.x.Pos(1))-1)) ~= 0
            Mario.somethingLeft = true;
        else
            Mario.somethingRight = false;
            Mario.somethingLeft = false;
        end
    elseif Mario.NegDir
        if any(amapClearData(floor(Mario.y.Pos(1))+1:floor(Mario.y.Pos(2))-1,floor(Mario.x.Pos(1))+1)) ~= 0
            Mario.somethingRight = true;
        elseif any(amapClearData(floor(Mario.y.Pos(1))+1:floor(Mario.y.Pos(2))-1,ceil(Mario.x.Pos(2))-1)) ~= 0
            Mario.somethingLeft = true;
        else
            Mario.somethingRight = false;
            Mario.somethingLeft = false;
        end
    end
        % Ceiling Detection
        % Checks row of transparent image data above Mario. If any of them
        % are not transparent, e.g. not zero, then something is above him,
        % Mario.somethingAbove will become true and later code will tell
        % him to bounce back down
        if Mario.PosDir
            if any(amapClearData(floor(Mario.y.Pos(1))+1,floor(Mario.x.Pos(1)+10):floor(Mario.x.Pos(2))-10)) ~= 0
                Mario.somethingAbove = true;
            else
                Mario.somethingAbove = false;
            end
        elseif Mario.NegDir
            if any(amapClearData(floor(Mario.y.Pos(1))+1,floor(Mario.x.Pos(2)+10):floor(Mario.x.Pos(1))-10)) ~= 0
                Mario.somethingAbove = true;
            else
                Mario.somethingAbove = false;
            end
        end
        
    % Terminal Velocity Speed Control
    % If Mario's x speed is too great, keep him at that speed
    if Mario.x.Vel > Mario.x.TermVel
        Mario.x.Vel = Mario.x.TermVel;
    elseif Mario.x.Vel < -Mario.x.TermVel
        Mario.x.Vel = -Mario.x.TermVel;
    else % Otherwise calculate velocity using Newtonian physics
        Mario.x.Vel = Mario.x.Vel + 5*Mario.x.Acc*dt;
    end
    
    % Slowing Down Speed Control
    % If Mario is Slowing Down while Going Left
    % When his velocity reaches zero, stop him completely
    if Mario.x.SlowA
        if Mario.x.Vel >= 0
            Mario.x.Acc = 0;
            Mario.x.Vel = 0;
            Mario.x.SlowA = false;
        end
    end
    % If Mario is Slowing Down while Going Right
    % When his velocity reaches zero, stop him completely
    if Mario.x.SlowD
        if Mario.x.Vel <= 0
            Mario.x.Acc = 0;
            Mario.x.Vel = 0;
            Mario.x.SlowD = false;
        end
    end
    
    % Position Collision Calculations and Exceptions
    % If Mario has something to the right and he is going right, stop him
    if Mario.somethingRight && Mario.x.Vel > 0
        Mario.x.Pos = Mario.x.Pos;
        % If Mario has something to the left and he is going left, stop him
    elseif Mario.somethingLeft && Mario.x.Vel < 0
        Mario.x.Pos = Mario.x.Pos;
    else % Otherwise abide by Newtonian Physics
        Mario.x.Pos = Mario.x.Pos + 5*Mario.x.Vel*dt;
    end
    
    % Out of Bounds Errors
    % Limit his left bounds
    if (Mario.x.Pos(1) < 4) || (Mario.x.Pos(2) < 4)
        if Mario.x.Vel > 0
            Mario.x.Pos = [5 20+5];
        else Mario.x.Pos = [20+5 5];
        end
        % Beat the World!
        % If Mario reaches the flag, stop him at that height
    elseif (Mario.x.Pos(1) > 3184) || (Mario.x.Pos(2) > 3184)
        beatTheGame = true;
        Mario.x.Vel = 0;
        Mario.x.Pos = [3185-20 3185];
        while beatTheGame
            Mario.y.Vel = Mario.y.Vel + Mario.y.Acc*dt;
            Mario.y.Pos = Mario.y.Pos + Mario.y.Vel*dt;
            if (Mario.y.Pos(2) > 192)
                break
            end
            set(m,'XData',Mario.x.Pos,'YData',Mario.y.Pos);
        end
        MarioIsDead
    end
    
    % Center Position
    Mario.x.Center = (Mario.x.Pos(1)+Mario.x.Pos(2))/2;
    
    % Update Position of Mario
    set(m,'XData',Mario.x.Pos,'YData',Mario.y.Pos);
    
    % Mario Running Animation
    % Using tic toc timer
    if Mario.x.Vel ~= 0 && ~beatTheGame
        tic;
        if runTime >= 0 && runTime < 0.08
            set(m,'CData', Mario.ImData.BRun1, 'AlphaData', Mario.ImData.ABr1);
            drawnow
        elseif runTime >= 0.08 && runTime < 0.16
            set(m,'CData', Mario.ImData.BRun2, 'AlphaData', Mario.ImData.ABr2);
            drawnow
        elseif runTime >= 0.16 && runTime < 0.24
            set(m,'CData', Mario.ImData.BRun3, 'AlphaData', Mario.ImData.ABr3);
            drawnow
        end
        runTime = runTime + toc;
        if runTime >= 0.24
            runTime = 0;
        end
    else %return to standing
        set(m,'CData', Mario.ImData.BStand, 'AlphaData', Mario.ImData.ABst);
        drawnow
    end
    
    % Update background only if moving right
    if Mario.x.Center >= Axes.Center
        Axes.Limits(1) = Mario.x.Center-150;
        Axes.Limits(2) = Mario.x.Center+150;
        Axes.Center = (Axes.Limits(1)+Axes.Limits(2))/2;
    end
    axis(Axes.Limits)
    drawnow
    
    % Goombas!
    % Goomba Spawning according to Mario's Position on Map
    if Mario.x.Pos(2) > GoomSpawnDist(n) && ~GoomActivate(n)
        GoomActivate(n) = true;
        goom{n} = image([GoomSpawnLoc2(n), GoomSpawnLoc2(n)],[192 208],Enemies.ImData.Goom1,'AlphaData',Enemies.ImData.AG1);
        if n == 5 || n == 6
            set(goom{n},'YData',[64 80])
        end
        % Wait until Mario passes the next (n+1) Goomba
        n = n+1;
    end
    % For all the current spawned goombas, move them left continuously
    for kk = 1:n-1
        Goom = goom{kk};
        Goomba.x.Pos = Goom.XData;
        set(Goom,'XData',Goomba.x.Pos-1000*dt)
    end
end
%% Other Functions
    function MarioIsDead()
        % If Mario dies close everything in this window,
        % display the controls, wait 4 seconds and play again!
        close(hFig)
        stop(Mario.Music)   % stop music
        imshow(imread('MarioControls.jpg'));    % load controls screen
        finishText = text(130,165, 'You Lost','FontSize', 25, 'Color', 'w');
        pause(4)    % pause for 4 seconds to give user time
        delete(finishText)  % delete message
        close all
        clear
        RUNMARIO
    end
%     function MarioWin()
%         % If Mario wins the game, close everything in this window,
%         % display the controls, wait 4 seconds and play again!
%         close(hFig)
%         stop(Mario.Music)   % stop music
%         imshow(imread('MarioControls.jpg'));    % load controls screen
%         finishText = text(130,165, 'You Won','FontSize', 25, 'Color', 'w');
%         pause(4)    % pause for 4 seconds to give user time
%         delete(finishText)  % delete message
%         beatTheGame = false;    % Now he has not beaten the game
%         close all
%         clear
%         RUNMARIO    % Play Again!
%     end
%% Callback Functions
    function moveMario(~,edata)
        % Utilizes key presses to move the x/y coordinates of Mario
        switch edata.Key
            case 'k'    % Jump
                JumpKeyStatus = true;
            case 'a'    % Left
                if ~Mario.NegDir && Mario.PosDir
                    Mario.x.Pos(1) = Mario.x.Pos(1)+20;
                    Mario.x.Pos(2) = Mario.x.Pos(1)-20;
                    Mario.NegDir = true;
                    Mario.PosDir = false;
                end
                Mario.x.Acc = negVel;
            case 'd'    % Right
                if Mario.NegDir && ~Mario.PosDir
                    Mario.x.Pos(1) = Mario.x.Pos(1)-20;
                    Mario.x.Pos(2) = Mario.x.Pos(1)+20;
                    Mario.NegDir = false;
                    Mario.PosDir = true;
                end
                Mario.x.Acc = posVel;
            case 'q'    % Quit
                close(hFig)
                quitInd = true;
                stop(Mario.Music)
        end
    end
    function stopMario(~,eData)
        % Utilizes key releases to determine whether to stop moving or not
        switch eData.Key
            case 'k'    % Jump
                JumpKeyStatus = false;
            case 'a'    % Left
                if Mario.x.Vel < 0
                    if Mario.x.Acc < 0
                        Mario.x.Acc = -Mario.x.Acc*3;
                        Mario.x.SlowA = true;
                    end
                end
            case 'd'    % Right
                if Mario.x.Vel > 0
                    if Mario.x.Acc > 0
                        Mario.x.Acc = -Mario.x.Acc*3;
                        Mario.x.SlowD = true;
                    end
                end
        end
    end
end

% Thanks for Playing!
