function [values,isValid] = XMLfun(S,nodeNameToFind,funcOrAttributeName)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    arguments
        S (1,1) struct {mustBeXMLElementStruct}
        nodeNameToFind {mustBeText}
        funcOrAttributeName {mustBeFunctionHandleOrAttrName}
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


%% Actual func here
    if isa(funcOrAttributeName, 'function_handle')
        useFunc = funcOrAttributeName;
    else
        useFunc = @(x) getAttrValue(x,funcOrAttributeName);
    end    
    values = nodefunc(S, '', nodeNameToFind, useFunc);

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
