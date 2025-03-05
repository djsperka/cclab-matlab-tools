function [values] = XMLfun(SorF,nodeNameToFind,funcOrAttributeName)
%XMLfun Pull attribute values out of an xml file, or perform a function at
%each node with a given name.
%   This function parses the xml file (the struct returned for a file 
% parsed with parseXML can also be passed), and traverses the xml tree
% (depth-first) looking for any nodes named 'nodeNameToFind' (use dotted
% notation). If found, one of two things can happen. If
% 'funcOrAttributeName' is a function handle, then that function is called
% with the current node as its only argument. If 'funcOrAttributeName' is a
% character vector or cell string, then the values should be Attribute
% names, and the values associated with each attribute are returned in a
% cell array of the same shape as 'funcOrAttrName'. 
%
% Simple case: Find the values of attribute 'filename' in the node
% 'PVScan.Sequence.Frame.File':
%
% > values = XMLfun(filename, 'PVScan.Sequence.Frame.File', 'filename');
% > values
% values =
% 
%   16×1 cell array
% 
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%     {'ds0345a-002_Cycle00001_Ch2_000001.ome.tif'}
%
% More complicated case: same as above, but get values for attributes
% 'filename' and 'channel':
% 
% > values = XMLfun(f, 'PVScan.Sequence.Frame.File', {'channel','filename'});
% > values{1}
% ans =
% 
%   1×2 cell array
% 
%     {'1'}    {'ds0345a-002_Cycle00001_Ch1_000001.ome.tif'}
%


    if isstruct(SorF)
        S = SorF;
    elseif ischar(SorF) && exist(SorF,'file')==2
        S = parseXML(SorF);
    else
        error('First arg must be a struct (from a parsed XML file) or an xml filename.');
    end

    if isa(funcOrAttributeName, 'function_handle')
        useFunc = funcOrAttributeName;
    else
        useFunc = @(x) getAttrValue(x,funcOrAttributeName);
    end    
    values = nodefunc(S, '', nodeNameToFind, useFunc);

end

function [val] = nodefunc(sNode,toThisPoint,seekingThisNodeName,f)

    if isempty(toThisPoint)
        thisNodeName = sNode.Name;
    else
        thisNodeName = [toThisPoint,'.',sNode.Name];
    end

    % Compare current node name to that which we seek. 
    % If found, run func against the node and collect output. Do NOT
    % visit children, as they cannot have same name as the current
    % node. If the name is not found, then visit children.
    %values = {};
    if strcmp(seekingThisNodeName,thisNodeName)
        %fprintf('Found node at depth %s\n', toThisPoint);
        val = {f(sNode)};
    else
        %fprintf('nodefunc at node: %s - visit Children\n',thisNodeName);
        val = {};
        for i=1:length(sNode.Children)
            vtmp=nodefunc(sNode.Children(i), thisNodeName, seekingThisNodeName, f);
            if ~isempty(vtmp)
                val = vertcat(val, vtmp);
                %val{end+1} = vtmp;
            end
        end
    end
end

function mustBeXMLElementStruct(s)
    assert(all(ismember(fieldnames(s), {'Name','Attributes','Data','Children'})));
end

function mustBeFunctionHandleOrEmpty(f)
    assert(isempty(f) || isa(f,'function_handle'));
end

function mustBeFunctionHandleOrAttrName(f)
    assert(ischar(f) || iscellstr(f) || isa(f,'function_handle'));
end

function [v] = getAttrValue(node,attrName)

    % If attrname is a cellstr list
    if ischar(attrName)
        v=[];
        for i=1:length(node.Attributes)
            if strcmp(node.Attributes(i).Name, attrName)
                v = node.Attributes(i).Value;
                break;
            end
        end
    else
        v = cell(size(attrName));
        for i=1:length(node.Attributes)
            vtmp = strcmp(node.Attributes(i).Name, attrName);
            if any(vtmp)
                v{vtmp} = node.Attributes(i).Value;
            end
        end
    end
end


function printAttributes(node)
    for i=1:length(node.Attributes)
        fprintf('Name: %s Value: %s\n', node.Attributes(i).Name, node.Attributes(i).Value);
    end
end
