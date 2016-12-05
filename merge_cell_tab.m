function cell_merge = merge_cell_tab(cell_master,cell_slave,opt)
% Merging cell table's rows ( One master celll table and one slave)
%
% SYNTAX:
% CELL_MERGE = MERGE_CELL_TAB(CELL_MASTER,CELL_SLAVE,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% CELL_MASTER     
%       (cell of string) the cell table that is used as master
% 
% CELL_SLAVE     
%       (cell of string) the cell table that is used as slave
% 
% OPT
%   (structure, optional) with the following fields:
%
%   HEADER
%       (boolean, default true) if true the first row are the table's headers.
%
%   MERGE_MASTER_COLUMN
%       (number, default '1') The master column index to use as reference for merging.
%
%   MERGE_SLAVE_COLOMN
%       (number, default '1') The slave column index to use as reference for merging.
%
% _________________________________________________________________________
% OUTPUTS:
%
% CELL_MERGE
%   (cell of strings) CELL{i,j} is a string corresponding to the ith row
%   and jth column of the Master cell tab merged with the corresponding ith row
%   and jth column of the Slave cell tab.
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_WRITE_CSV_CELL
% NIAK_READ_CSV_CELL
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Yassine Benhajali, Pierre Bellec,
% Centre de recherche de l'institut de griatrie de Montral, 
% Department of Computer Science and Operations Research
% University of Montreal, Qubec, Canada, 2013
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : table, CSV

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Set Default inputs
if ~exist('cell_master','var')||~exist('cell_slave','var')
    error('Please specify CELL_MASTER and CELL_SLAVE as inputs');
end

%% Set default options
list_fields   = {'header' , 'merge_master_colomn' , 'merge_slave_colomn' };
list_defaults = { true    , 1                       , 1                      };
if nargin == 2
   opt = psom_struct_defaults(struct(),list_fields,list_defaults);
else 
   opt = psom_struct_defaults(opt,list_fields,list_defaults);
end

% Loop over ID's and merge master with slave
fprintf('merging master cell tab "%s" with slave cell tab "%s":\n', inputname(1),inputname(2));
cell_merge = cell(size(cell_master,1),size(cell_slave,2)+size(cell_master,2));
n_shift = 0;
for n_cell_master = 2:size(cell_master(1:end,opt.merge_master_colomn),1)
    niak_progress( n_cell_master , length(cell_master(1:end,opt.merge_master_colomn)))
    n_rep = 0;
    for n_cell_slave = 2:size(cell_slave(1:end,opt.merge_slave_colomn),1)
        subj_match = strfind(cell_master{n_cell_master,opt.merge_master_colomn},char(cell_slave{n_cell_slave,opt.merge_slave_colomn}));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              cell_merge(n_cell_master + n_shift,:) = [ cell_master(n_cell_master,:)  cell_slave(n_cell_slave,:) ];
           else
              cell_merge(n_cell_master + n_shift,:) = [ cell_master(n_cell_master,:)  cell_slave(n_cell_slave,:) ];
           end
        end
    end
    if n_rep == 0
    cell_merge(n_cell_master + n_shift ,:) = [ cell_master(n_cell_master,:) cell(size(cell_slave(n_cell_slave,:)))  ];
    end
end
cell_merge(cellfun(@isempty,cell_merge))=NaN;

% add tables headers
cell_merge(1,:) = [ cell_master(1,:)  cell_slave(1,:) ];
