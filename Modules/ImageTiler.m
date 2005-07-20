function handles = ImageTiler(handles)

% Help for the Image Tiler module:
% Category: Image Processing
%
% Allows many images to be viewed simultaneously, in a grid layout you
% specify (e.g. in the actual layout in which the images were
% collected).
%
% If you want to view a large number of images, you will generate an
% extremely large file (roughly the MB of all the images added
% together) which, even if it could be created by Matlab, could not be
% opened by any image software anyway. Matlab has a limit to the
% amount of data it can open which prevents you from creating such a
% gigantic, high resolution file.  There are several ways to allow a
% larger image to be produced, given memory limitations: (1) Decrease
% the resolution of each image tile by entering a fraction where
% requested. Then, in the window which pops open after ImageTiler
% finishes, you can use the 'Get high res image' button to retrieve
% the original high resolution image. (This button is not yet
% functional). (2) Use the SpeedUpCellProfiler module to clear out
% images that are stored in memory. Place this module just prior to
% the ImageTiler module and ask it to retain only those images which
% are needed for downstream modules.  (3) Rescale the images to 8 bit
% format by putting in the RescaleImages module just prior to the
% ImageTiler module. Normally images are stored in memory as class
% "double" which takes about 10 times the space of class "uint8" which
% is 8 bits.  You will lose resolution in terms of the number of
% different graylevels - this will be limited to 256 - but you will
% not lose spatial resolution.
%
% The file name (automatic) and sample info (optional) can be
% displayed on each image using buttons in the final figure window.
%
% SAVING IMAGES: The tiled image produced by this module can be easily
% saved using the Save Images module, using the name you assign. If
% you want to save other intermediate images, alter the code for this
% module to save those images to the handles structure (see the
% SaveImages module help) and then use the Save Images module.
%
% See also SPOTIDENTIFIER.

% CellProfiler is distributed under the GNU contGeneral Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   Anne Carpenter <carpenter@wi.mit.edu>
%   Thouis Jones   <thouis@csail.mit.edu>
%   In Han Kang    <inthek@mit.edu>
%
% $Revision$

% PROGRAMMING NOTE
% HELP:
% The first unbroken block of lines will be extracted as help by
% CellProfiler's 'Help for this analysis module' button as well as Matlab's
% built in 'help' and 'doc' functions at the command line. It will also be
% used to automatically generate a manual page for the module. An example
% image demonstrating the function of the module can also be saved in tif
% format, using the same name as the module, and it will automatically be
% included in the manual page as well.  Follow the convention of: purpose
% of the module, description of the variables and acceptable range for
% each, how it works (technical description), info on which images can be
% saved, and See also CAPITALLETTEROTHERMODULES. The license/author
% information should be separated from the help lines with a blank line so
% that it does not show up in the help displays.  Do not change the
% programming notes in any modules! These are standard across all modules
% for maintenance purposes, so anything module-specific should be kept
% separate.

% PROGRAMMING NOTE
% DRAWNOW:
% The 'drawnow' function allows figure windows to be updated and
% buttons to be pushed (like the pause, cancel, help, and view
% buttons).  The 'drawnow' function is sprinkled throughout the code
% so there are plenty of breaks where the figure windows/buttons can
% be interacted with.  This does theoretically slow the computation
% somewhat, so it might be reasonable to remove most of these lines
% when running jobs on a cluster where speed is important.
drawnow

%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%

% PROGRAMMING NOTE
% VARIABLE BOXES AND TEXT:
% The '%textVAR' lines contain the variable descriptions which are
% displayed in the CellProfiler main window next to each variable box.
% This text will wrap appropriately so it can be as long as desired.
% The '%defaultVAR' lines contain the default values which are
% displayed in the variable boxes when the user loads the module.
% The line of code after the textVAR and defaultVAR extracts the value
% that the user has entered from the handles structure and saves it as
% a variable in the workspace of this module with a descriptive
% name. The syntax is important for the %textVAR and %defaultVAR
% lines: be sure there is a space before and after the equals sign and
% also that the capitalization is as shown.
% CellProfiler uses VariableRevisionNumbers to help programmers notify
% users when something significant has changed about the variables.
% For example, if you have switched the position of two variables,
% loading a pipeline made with the old version of the module will not
% behave as expected when using the new version of the module, because
% the settings (variables) will be mixed up. The line should use this
% syntax, with a two digit number for the VariableRevisionNumber:
% '%%%VariableRevisionNumber = 01'  If the module does not have this
% line, the VariableRevisionNumber is assumed to be 00.  This number
% need only be incremented when a change made to the modules will affect
% a user's previously saved settings. There is a revision number at
% the end of the license info at the top of the m-file for revisions
% that do not affect the user's previously saved settings files.

%%% Reads the current module number, because this is needed to find
%%% the variable values that the user entered.
CurrentModule = handles.Current.CurrentModuleNumber;
CurrentModuleNum = str2double(CurrentModule);

%textVAR01 = What did you call the images to be tiled?
%infotypeVAR01 = imagegroup
ImageName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What were the images called when the were originally loaded?
%infotypeVAR02 = imagegroup
OrigImageName = char(handles.Settings.VariableValues{CurrentModuleNum,2});
%inputtypeVAR02 = popupmenu

%textVAR03 = What do you want to call the tiled image?
%infotypeVAR03 = imagegroup indep
%defaultVAR03 = TiledImage
TiledImageName = char(handles.Settings.VariableValues{CurrentModuleNum,3});

%textVAR04 = Number of rows to display.
%choiceVAR04 = Automatic
NumberRows = char(handles.Settings.VariableValues{CurrentModuleNum,4});
%inputtypeVAR04 = popupmenu custom

%textVAR05 = Number of columns to display.
%choiceVAR05 = Automatic
NumberColumns = char(handles.Settings.VariableValues{CurrentModuleNum,5});
%inputtypeVAR05 = popupmenu custom

%textVAR06 = Are the first two images arranged in a row or a column?
%choiceVAR06 = Column
%choiceVAR06 = Row
RowOrColumn = char(handles.Settings.VariableValues{CurrentModuleNum,6});
%inputtypeVAR06 = popupmenu

%textVAR07 = Is the first image at the bottom or the top?
%choiceVAR07 = Top
%choiceVAR07 = Bottom
TopOrBottom = char(handles.Settings.VariableValues{CurrentModuleNum,7});
%inputtypeVAR07 = popupmenu

%textVAR08 = Is the first image at the left or the right?
%choiceVAR08 = Left
%choiceVAR08 = Right
LeftOrRight = char(handles.Settings.VariableValues{CurrentModuleNum,8});
%inputtypeVAR08 = popupmenu

%textVAR09 = What fraction should the images be sized (the resolution will be changed)?
%defaultVAR09 = .1
SizeChange = char(handles.Settings.VariableValues{CurrentModuleNum,9});
SizeChange = str2num(SizeChange);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Reads (opens) the image you want to analyze and assigns it to a
%%% variable.

%%% Checks whether the image to be analyzed exists in the handles structure.
if isfield(handles.Pipeline, ImageName) == 0
    %%% If the image is not there, an error message is produced.  The error
    %%% is not displayed: The error function halts the current function and
    %%% returns control to the calling function (the analyze all images
    %%% button callback.)  That callback recognizes that an error was
    %%% produced because of its try/catch loop and breaks out of the image
    %%% analysis loop without attempting further modules.
    error(['Image processing was canceled because the Image Tiler module could not find the input image.  It was supposed to be named ', ImageName, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
end

%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%
drawnow

% PROGRAMMING NOTE
% TO TEMPORARILY SHOW IMAGES DURING DEBUGGING:
% figure, imshow(BlurredImage, []), title('BlurredImage')
% TO TEMPORARILY SAVE IMAGES DURING DEBUGGING:
% imwrite(BlurredImage, FileName, FileFormat);
% Note that you may have to alter the format of the image before
% saving.  If the image is not saved correctly, for example, try
% adding the uint8 command:
% imwrite(uint8(BlurredImage), FileName, FileFormat);
% To routinely save images produced by this module, see the help in
% the SaveImages module.

if handles.Current.SetBeingAnalyzed == 1
    %%% Retrieves the path where the images are stored from the handles
    %%% structure.
    fieldname = ['Pathname', OrigImageName];
    try Pathname = handles.Pipeline.(fieldname);
    catch error('Image processing was canceled because the Image Tiler module must be run using images straight from a load images module (i.e. the images cannot have been altered by other image processing modules). This is because the Image Tiler module calculates an illumination correction image based on all of the images before correcting each individual image as CellProfiler cycles through them. One solution is to process the entire batch of images using the image analysis modules preceding this module and save the resulting images to the hard drive, then start a new stage of processing from this Image Tiler module onward.')
    end
    %%% Retrieves the list of filenames where the images are stored from the
    %%% handles structure.
    fieldname = ['FileList', OrigImageName];
    FileList = handles.Pipeline.(fieldname);
    NumberOfImages = length(FileList);
    if strcmp(NumberRows,'Automatic') == 1 && strcmp(NumberColumns,'Automatic')== 1
        %%% Calculates the square root in order to determine the dimensions
        %%% of the display grid.
        SquareRoot = sqrt(NumberOfImages);
        %%% Converts the result to an integer.
        NumberRows = fix(SquareRoot);
        NumberColumns = ceil((NumberOfImages)/NumberRows);
    elseif strcmp(NumberRows,'Automatic')
        NumberColumns = str2double(NumberColumns);
        NumberRows = ceil((NumberOfImages)/NumberColumns);
    elseif strcmp(NumberColumns,'Automatic')
        NumberRows = str2double(NumberRows);
        NumberColumns = ceil((NumberOfImages)/NumberRows);
    else NumberColumns = str2double(NumberColumns);
        NumberRows = str2double(NumberRows);
    end
    if NumberRows*NumberColumns > NumberOfImages;
        Answer = CPquestdlg(['You have specified ', num2str(NumberRows), ' rows and ', num2str(NumberColumns), ' columns (=',num2str(NumberRows*NumberColumns),' images), but there are ', num2str(length(FileList)), ' images loaded. The image locations at the end of the grid for which there is no image data will be displayed as black. Do you want to continue?'],'Continue?','Yes','No','Yes');
        if strcmp(Answer,'No') == 1
            return
        end
        FileList(length(FileList)+1:NumberRows*NumberColumns) = {'none'};
    elseif NumberRows*NumberColumns < NumberOfImages;
        Answer = CPquestdlg(['You have specified ', num2str(NumberRows), ' rows and ', num2str(NumberColumns), ' columns (=',num2str(NumberRows*NumberColumns),' images), but there are ', num2str(length(FileList)), ' images loaded. Images at the end of the list will not be displayed. Do you want to continue?'],'Continue?','Yes','No','Yes');
        if strcmp(Answer,'No') == 1
            return
        end
        FileList(NumberRows*NumberColumns+1:NumberOfImages) = [];
    end
    
    if strcmp(RowOrColumn,'Row')
        NewFileList = reshape(FileList,NumberColumns,NumberRows);
        NewFileList = NewFileList';
    elseif strcmp(RowOrColumn,'Column')
        NewFileList = reshape(FileList,NumberRows,NumberColumns);
    end
    if strcmp(LeftOrRight,'Right')
        NewFileList = fliplr(NewFileList);
    end
    if strcmp(TopOrBottom,'Bottom')
        NewFileList = flipud(NewFileList);
    end    
    
    NumberOfImages = NumberColumns*NumberRows;
    
    LoadedImage = handles.Pipeline.(ImageName);
    ImageSize = size(imresize(LoadedImage,SizeChange));
    ImageHeight = ImageSize(1);
    ImageWidth = ImageSize(2);
    TotalWidth = NumberColumns*ImageWidth;
    TotalHeight = NumberRows*ImageHeight;
    %%% Packs the workspace to free up memory since a large variable is about to be produced.
    pack;
    %%% Preallocates the array to improve speed. The data class for
    %%% the tiled image is set to match the incoming image's class.
    TiledImage = zeros(TotalHeight,TotalWidth,size(LoadedImage,3),class(LoadedImage));
    
    ImageTilerDataToSave.NumberColumns = NumberColumns;
    ImageTilerDataToSave.NumberRows = NumberRows;
    ImageTilerDataToSave.ImageHeight = ImageHeight;
    ImageTilerDataToSave.ImageWidth = ImageWidth;
    ImageTilerDataToSave.NewFileList = NewFileList;
    ImageTilerDataToSave.TotalWidth = TotalWidth;
    ImageTilerDataToSave.TotalHeight = TotalHeight; 
    ImageTilerDataToSave.TiledImage = TiledImage; 
    
    %stores data in handles
    handles.Pipeline.ImageTilerData.(['Module' handles.Current.CurrentModuleNumber]) = ImageTilerDataToSave;
end

%gets data from handles
RetrievedImageTilerData = handles.Pipeline.ImageTilerData.(['Module' handles.Current.CurrentModuleNumber]);

TiledImage = RetrievedImageTilerData.TiledImage;
NumberColumns = RetrievedImageTilerData.NumberColumns;
ImageHeight = RetrievedImageTilerData.ImageHeight;
ImageWidth = RetrievedImageTilerData.ImageWidth;
NumberColumns = RetrievedImageTilerData.NumberColumns;
NumberRows = RetrievedImageTilerData.NumberRows;

CurrentImage = handles.Pipeline.(ImageName);
CurrentImage = imresize(CurrentImage,SizeChange);

if strcmp(RowOrColumn,'Column')
    HorzPos = floor((handles.Current.SetBeingAnalyzed-1)/NumberRows);
    VertPos = handles.Current.SetBeingAnalyzed - HorzPos*NumberRows-1;
elseif strcmp(RowOrColumn,'Row')
    VertPos = floor((handles.Current.SetBeingAnalyzed-1)/NumberColumns);
    HorzPos = handles.Current.SetBeingAnalyzed - VertPos*NumberColumns-1;
end

if strcmp(TopOrBottom,'Bottom')
    VertPos = NumberRows - VertPos-1;
end

if strcmp(LeftOrRight,'Right')
    HorzPos = NumberColumns - HorzPos-1;
end

%%% Memory errors can occur here if the tiled image is too big.
TiledImage((ImageHeight*VertPos)+(1:ImageHeight),(ImageWidth*HorzPos)+(1:ImageWidth),:) = CurrentImage(:,:,:);
handles.Pipeline.ImageTilerData.(['Module' handles.Current.CurrentModuleNumber]).TiledImage = TiledImage;

if handles.Current.SetBeingAnalyzed == handles.Current.NumberOfImageSets

    %%%%%%%%%%%%%%%%%%%%%%
    %%% DISPLAY RESULTS %%%
    %%%%%%%%%%%%%%%%%%%%%%
    drawnow

    %gets data from handles
    RetrievedImageTilerData = handles.Pipeline.ImageTilerData.(['Module' handles.Current.CurrentModuleNumber]);
    TiledImage = RetrievedImageTilerData.TiledImage;
    NumberColumns = RetrievedImageTilerData.NumberColumns;
    ImageHeight = RetrievedImageTilerData.ImageHeight;
    ImageWidth = RetrievedImageTilerData.ImageWidth;
    NumberColumns = RetrievedImageTilerData.NumberColumns;
    NumberRows = RetrievedImageTilerData.NumberRows;
    TotalWidth = RetrievedImageTilerData.TotalWidth;
    TotalHeight = RetrievedImageTilerData.TotalHeight;
    NewFileList = RetrievedImageTilerData.NewFileList;

    fieldname = ['FigureNumberForModule',CurrentModule];
    ThisModuleFigureNumber = handles.Current.(fieldname);
    if any(findobj == ThisModuleFigureNumber) == 1;
    % PROGRAMMING NOTE
    % DRAWNOW BEFORE FIGURE COMMAND:
    % The "drawnow" function executes any pending figure window-related
    % commands.  In general, Matlab does not update figure windows until
    % breaks between image analysis modules, or when a few select commands
    % are used. "figure" and "drawnow" are two of the commands that allow
    % Matlab to pause and carry out any pending figure window- related
    % commands (like zooming, or pressing timer pause or cancel buttons or
    % pressing a help button.)  If the drawnow command is not used
    % immediately prior to the figure(ThisModuleFigureNumber) line, then
    % immediately after the figure line executes, the other commands that
    % have been waiting are executed in the other windows.  Then, when
    % Matlab returns to this module and goes to the subplot line, the
    % figure which is active is not necessarily the correct one. This
    % results in strange things like the subplots appearing in the timer
    % window or in the wrong figure window, or in help dialog boxes.
        drawnow
        %%% Activates the appropriate figure window.
        CPfigure(handles,ThisModuleFigureNumber);
        colormap(gray);
        %%% Displays the image.
        imagesc(TiledImage)
        %%% Sets the figure to take up most of the screen.
        ScreenSize = get(0,'ScreenSize');
        Font = handles.Current.FontSize;
        NewFigureSize = [60,250, ScreenSize(3)-200, ScreenSize(4)-350];
        set(ThisModuleFigureNumber, 'Position', NewFigureSize)
        axis image

        ToggleGridButtonFunction = ...
        ['Handles = findobj(''type'',''line'');'...
            'button = findobj(''Tag'',''ToggleGridButton'');'...
            'if strcmp(get(button,''String''),''Hide''),'...
                'set(button,''String'',''Show'');'...
                'set(Handles,''visible'',''off'');'...
            'else,'...
                'set(button,''String'',''Hide'');'...
                'set(Handles,''visible'',''on'');'...
            'end,'...
            'clear Handles button'];
        uicontrol('Style', 'pushbutton', ...
            'String', 'Hide', 'Position', [10 6 45 20], 'BackgroundColor',[.7 .7 .9],...
            'Callback', ToggleGridButtonFunction, 'parent',ThisModuleFigureNumber,'FontSize',Font,'Tag','ToggleGridButton');
        ChangeGridButtonFunction = 'Handles = findobj(''type'',''line''); propedit(Handles); clear Handles';
        uicontrol('Style', 'pushbutton', ...
            'String', 'Change', 'Position', [60 6 45 20],'BackgroundColor',[.7 .7 .9], ...
            'Callback', ChangeGridButtonFunction, 'parent',ThisModuleFigureNumber,'FontSize',Font);

        ToggleFileNamesButtonFunction = ...
        ['Handles = findobj(''UserData'',''FileNameTextHandles'');'...
            'button = findobj(''Tag'',''ToggleFileNamesButton'');'...
            'if strcmp(get(button,''String''),''Hide''),'...
                'set(button,''String'',''Show'');'...
                'set(Handles,''visible'',''off'');'...
            'else,'...
                'set(button,''String'',''Hide'');'...
                'set(Handles,''visible'',''on'');'...
            'end,'...
            'clear Handles button'];
        uicontrol('Style', 'pushbutton', ...
            'String', 'Show', 'Position', [120 6 45 20], 'BackgroundColor',[.7 .7 .9],...
            'Callback', ToggleFileNamesButtonFunction, 'parent',ThisModuleFigureNumber,'FontSize',Font,'Tag','ToggleFileNamesButton');
        ChangeFileNamesButtonFunction = 'Handles = findobj(''UserData'',''FileNameTextHandles''); propedit(Handles); clear Handles';
        uicontrol('Style', 'pushbutton', 'BackgroundColor',[.7 .7 .9],...
            'String', 'Change', 'Position', [170 6 45 20], ...
            'Callback', ChangeFileNamesButtonFunction, 'parent',ThisModuleFigureNumber,'FontSize',Font);

        ChangeColormapButtonFunction = 'ImageHandle = findobj(gca, ''type'',''image''); propedit(ImageHandle)';
        uicontrol('Style', 'pushbutton', ...
            'String', 'Change', 'Position', [230 6 45 20], 'BackgroundColor',[.7 .7 .9],...
            'Callback', ChangeColormapButtonFunction, 'parent',ThisModuleFigureNumber,'FontSize',Font);

        uicontrol('Parent',ThisModuleFigureNumber, ...
            'BackgroundColor',get(ThisModuleFigureNumber,'Color'), ...
            'Position',[10 28 95 14], ...
            'HorizontalAlignment','center', ...
            'String','Gridlines:', ...
            'Style','text', ...
            'FontSize',Font);
        uicontrol('Parent',ThisModuleFigureNumber, ...
            'BackgroundColor',get(ThisModuleFigureNumber,'Color'), ...
            'Position',[120 28 95 14], ...
            'HorizontalAlignment','center', ...
            'String','File names:', ...
            'Style','text', ...
            'FontSize',Font);
        uicontrol('Parent',ThisModuleFigureNumber, ...
            'BackgroundColor',get(ThisModuleFigureNumber,'Color'), ...
            'Position',[230 28 55 14], ...
            'HorizontalAlignment','center', ...
            'String','Colormap:', ...
            'Style','text', ...
            'FontSize',Font);


        %%% Draws the grid on the image.  The 0.5 accounts for the fact that
        %%% pixels are labeled where the middle of the pixel is a whole number,
        %%% and the left hand side of each pixel is 0.5.
        X(1:2,:) = [(0.5:ImageWidth:TotalWidth+0.5);(0.5:ImageWidth:TotalWidth+0.5)];
        NumberVerticalLines = size(X');
        NumberVerticalLines = NumberVerticalLines(1);
        Y(1,:) = repmat(0,1,NumberVerticalLines);
        Y(2,:) = repmat(TotalHeight,1,NumberVerticalLines);
        line(X,Y)

        NewY(1:2,:) = [(0.5:ImageHeight:TotalHeight+0.5);(0.5:ImageHeight:TotalHeight+0.5)];
        NumberHorizontalLines = size(NewY');
        NumberHorizontalLines = NumberHorizontalLines(1);
        NewX(1,:) = repmat(0,1,NumberHorizontalLines);
        NewX(2,:) = repmat(TotalWidth,1,NumberHorizontalLines);
        line(NewX,NewY)

        Handles = findobj('type','line');
        set(Handles, 'color',[.15 .15 .15])

        %%% Sets the location of Tick marks.
        set(gca, 'XTick', ImageWidth/2:ImageWidth:TotalWidth-ImageWidth/2)
        set(gca, 'YTick', ImageHeight/2:ImageHeight:TotalHeight-ImageHeight/2)

        %%% Sets the Tick Labels.
        if strcmp(LeftOrRight,'Right') == 1
            set(gca, 'XTickLabel',fliplr(1:NumberColumns))
        else
            set(gca, 'XTickLabel', 1:NumberColumns)
        end
        if strcmp(TopOrBottom,'Bottom') == 1
            set(gca, 'YTickLabel',fliplr(1:NumberRows))
        else
            set(gca, 'YTickLabel', 1:NumberRows)
        end

        %%% Calculates where to display the file names on the tiled image.
        %%% Provides the i,j coordinates of the file names.  The
        %%% cellfun(length) part is just a silly way to get a number for every
        %%% entry in the NewFileList so that the find function can find it.
        %%% find does not work directly on strings in cell arrays.
        [i,j] = find(cellfun('length',NewFileList));
        YLocations = i*ImageHeight - ImageHeight/2;
        XLocations = j*ImageWidth - ImageWidth/2;
        OneColumnNewFileList = reshape(NewFileList,[],1);
        PrintableOneColumnNewFileList = strrep(OneColumnNewFileList,'_','\_');
        %%% Creates FileNameText
        text(XLocations, YLocations, PrintableOneColumnNewFileList,...
            'HorizontalAlignment','center', 'color', 'white','visible','off', ...
            'UserData','FileNameTextHandles') 
        set(ThisModuleFigureNumber,'toolbar','figure')
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% SAVE DATA TO HANDLES STRUCTURE %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    drawnow

    % PROGRAMMING NOTE
    % HANDLES STRUCTURE:
    %       In CellProfiler (and Matlab in general), each independent
    % function (module) has its own workspace and is not able to 'see'
    % variables produced by other modules. For data or images to be shared
    % from one module to the next, they must be saved to what is called
    % the 'handles structure'. This is a variable, whose class is
    % 'structure', and whose name is handles. The contents of the handles
    % structure are printed out at the command line of Matlab using the
    % Tech Diagnosis button. The only variables present in the main
    % handles structure are handles to figures and gui elements.
    % Everything else should be saved in one of the following
    % substructures:
    %
    % handles.Settings:
    %       Everything in handles.Settings is stored when the user uses
    % the Save pipeline button, and these data are loaded into
    % CellProfiler when the user uses the Load pipeline button. This
    % substructure contains all necessary information to re-create a
    % pipeline, including which modules were used (including variable
    % revision numbers), their setting (variables), and the pixel size.
    %   Fields currently in handles.Settings: PixelSize, ModuleNames,
    % VariableValues, NumbersOfVariables, VariableRevisionNumbers.
    %
    % handles.Pipeline:
    %       This substructure is deleted at the beginning of the
    % analysis run (see 'Which substructures are deleted prior to an
    % analysis run?' below). handles.Pipeline is for storing data which
    % must be retrieved by other modules. This data can be overwritten as
    % each image set is processed, or it can be generated once and then
    % retrieved during every subsequent image set's processing, or it can
    % be saved for each image set by saving it according to which image
    % set is being analyzed, depending on how it will be used by other
    % modules. Any module which produces or passes on an image needs to
    % also pass along the original filename of the image, named after the
    % new image name, so that if the SaveImages module attempts to save
    % the resulting image, it can be named by appending text to the
    % original file name.
    %   Example fields in handles.Pipeline: FileListOrigBlue,
    % PathnameOrigBlue, FilenameOrigBlue, OrigBlue (which contains the actual image).
    %
    % handles.Current:
    %       This substructure contains information needed for the main
    % CellProfiler window display and for the various modules to
    % function. It does not contain any module-specific data (which is in
    % handles.Pipeline).
    %   Example fields in handles.Current: NumberOfModules,
    % StartupDirectory, DefaultOutputDirectory, DefaultImageDirectory,
    % FilenamesInImageDir, CellProfilerPathname, ImageToolHelp,
    % DataToolHelp, FigureNumberForModule01, NumberOfImageSets,
    % SetBeingAnalyzed, TimeStarted, CurrentModuleNumber.
    %
    % handles.Preferences:
    %       Everything in handles.Preferences is stored in the file
    % CellProfilerPreferences.mat when the user uses the Set Preferences
    % button. These preferences are loaded upon launching CellProfiler.
    % The PixelSize, DefaultImageDirectory, and DefaultOutputDirectory
    % fields can be changed for the current session by the user using edit
    % boxes in the main CellProfiler window, which changes their values in
    % handles.Current. Therefore, handles.Current is most likely where you
    % should retrieve this information if needed within a module.
    %   Fields currently in handles.Preferences: PixelSize, FontSize,
    % DefaultModuleDirectory, DefaultOutputDirectory,
    % DefaultImageDirectory.
    %
    % handles.Measurements
    %      Data extracted from input images are stored in the
    % handles.Measurements substructure for exporting or further analysis.
    % This substructure is deleted at the beginning of the analysis run
    % (see 'Which substructures are deleted prior to an analysis run?'
    % below). The Measurements structure is organized in two levels. At
    % the first level, directly under handles.Measurements, there are
    % substructures (fields) containing measurements of different objects.
    % The names of the objects are specified by the user in the Identify
    % modules (e.g. 'Cells', 'Nuclei', 'Colonies').  In addition to these
    % object fields is a field called 'Image' which contains information
    % relating to entire images, such as filenames, thresholds and
    % measurements derived from an entire image. That is, the Image field
    % contains any features where there is one value for the entire image.
    % As an example, the first level might contain the fields
    % handles.Measurements.Image, handles.Measurements.Cells and
    % handles.Measurements.Nuclei.
    %      In the second level, the measurements are stored in matrices
    % with dimension [#objects x #features]. Each measurement module
    % writes its own block; for example, the MeasureAreaShape module
    % writes shape measurements of 'Cells' in
    % handles.Measurements.Cells.AreaShape. An associated cell array of
    % dimension [1 x #features] with suffix 'Features' contains the names
    % or descriptions of the measurements. The export data tools, e.g.
    % ExportData, triggers on this 'Features' suffix. Measurements or data
    % that do not follow the convention described above, or that should
    % not be exported via the conventional export tools, can thereby be
    % stored in the handles.Measurements structure by leaving out the
    % '....Features' field. This data will then be invisible to the
    % existing export tools.
    %      Following is an example where we have measured the area and
    % perimeter of 3 cells in the first image and 4 cells in the second
    % image. The first column contains the Area measurements and the
    % second column contains the Perimeter measurements.  Each row
    % contains measurements for a different cell:
    % handles.Measurements.Cells.AreaShapeFeatures = {'Area' 'Perimeter'}
    % handles.Measurements.Cells.AreaShape{1} = 	40		20
    %                                               100		55
    %                                              	200		87
    % handles.Measurements.Cells.AreaShape{2} = 	130		100
    %                                               90		45
    %                                               100		67
    %                                               45		22
    %
    % Which substructures are deleted prior to an analysis run?
    %       Anything stored in handles.Measurements or handles.Pipeline
    % will be deleted at the beginning of the analysis run, whereas
    % anything stored in handles.Settings, handles.Preferences, and
    % handles.Current will be retained from one analysis to the next. It
    % is important to think about which of these data should be deleted at
    % the end of an analysis run because of the way Matlab saves
    % variables: For example, a user might process 12 image sets of nuclei
    % which results in a set of 12 measurements ("ImageTotalNucArea")
    % stored in handles.Measurements. In addition, a processed image of
    % nuclei from the last image set is left in the handles structure
    % ("SegmNucImg"). Now, if the user uses a different algorithm which
    % happens to have the same measurement output name "ImageTotalNucArea"
    % to analyze 4 image sets, the 4 measurements will overwrite the first
    % 4 measurements of the previous analysis, but the remaining 8
    % measurements will still be present. So, the user will end up with 12
    % measurements from the 4 sets. Another potential problem is that if,
    % in the second analysis run, the user runs only a module which
    % depends on the output "SegmNucImg" but does not run a module that
    % produces an image by that name, the module will run just fine: it
    % will just repeatedly use the processed image of nuclei leftover from
    % the last image set, which was left in handles.Pipeline.

    %%% Saves the tiled image to the handles structure so it can be used by
    %%% subsequent modules.
    handles.Pipeline.(TiledImageName) = TiledImage;
end
