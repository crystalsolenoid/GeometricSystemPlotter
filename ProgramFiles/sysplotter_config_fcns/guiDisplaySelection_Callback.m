function guiDisplaySelection_Callback(hObject, eventdata, handles)
% hObject    handle to guiDisplayOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns guiDisplayOptions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from guiDisplayOptions

propertyMenuValue = get(handles.guiDisplaySelection,'Value');
% % GUIposition = get(handles.figPendulum,'Position');
%
if propertyMenuValue == 1 % default
    if ispc
        propertyFile = 'propertyDataPC.mat';
    elseif ismac
        propertyFile = 'propertyDataMAC.mat';
    elseif isunix
        propertyFile = 'propertyDataUNIX.mat';
    end
elseif propertyMenuValue == 2 % PC
    propertyFile = 'propertyDataPC.mat';
elseif propertyMenuValue == 3 % MAC
    propertyFile = 'propertyDataMAC.mat';
elseif propertyMenuValue == 4 % Custom
    %         uiopen
    propertyFile = uigetfile('*.mat','Select Property File');
end

set(handles.displayConfigFile,'String',propertyFile)

end