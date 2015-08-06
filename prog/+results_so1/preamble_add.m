function preamble_add(fieldNameStr, valueStr, commentStr, cS)
% Add a field to the results preamble
% ------------------------------------------------

% dirS = param_so1.directories(cS.gNo, cS.setNo);
varS = param_so1.var_numbers;

if ~ischar(valueStr)
   error('Value must be string');
end

% Remove special characters from field names (so latex does not choke)
% fieldNameStr = regexprep(fieldNameStr, '[_\\]', '');

% add_field changes non-Latex command compatible fields
preamble_lh.add_field(fieldNameStr,  valueStr, output_so1.var_fn(varS.vPreambleData, cS), commentStr);

fprintf('Preamble: added field %s  with value %s \n',  fieldNameStr, valueStr);

end