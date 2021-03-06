%Calculate the constraint curvature functions from the connection
function s = calc_constraint_curvature(s)

	%Apply to both raw and optimized connections
	Avec_names = {'','_optimized'};
	
	for i = 1:length(Avec_names)

		%Extract the high density "eval" vector field
		vecfield = s.vecfield.eval.content.(['Avec' Avec_names{i}]);

		%get the number of rows in the local connection (positon-space
		%dimensions)
		n_rows = size(vecfield,1);
		
		%get the number of columns in the local connection (shape space
		%dimensions)
		n_col = size(vecfield,2);
		
		% input order to convert ndgrid to meshgrid
		inputorder = [2 1 3:n_col];
		
		%Extract the high density grid
		grid = s.grid.eval;

		if n_col <= 3
	
			s.(['dA' Avec_names{i}]) = cell(n_rows,(n_col^2 - n_col)/2);
			s.(['DA' Avec_names{i}]) = cell(n_rows,(n_col^2 - n_col)/2);
			
				
		
		else % For dimensions not yet implemented. The 'return' skips over the processing that would break for string input
					
			s.(['dA' Avec_names{i}]) = 'Exterior derivative for n>3 not yet implemented';
			s.(['DA' Avec_names{i}]) = 'Exterior derivative for n>3 not yet implemented';
				
			return
				
		end
		
		% Build a selection matrix for pairs of vectors to form the
		% exterior-derivative basis
		if n_col==2
			
			basis_ordering = [1 2];
			
			curl_ordering = 1;
			
		elseif n_col == 3
			
			basis_ordering = [1 2; 2 3; 3 1];
			
			curl_ordering = [3 1 2];
					
		else
			
			% Use basis that in e_i ^ e_j, i < j
			basis_ordering = nchoosek(1:n_col,2);
		
		end

		%loop over the rows, generating curvature forms
		for j = 1:n_rows
			
			% Convert the data into meshgrid ordering
			vecfield_meshgrid = cellfun(@(x) permute(x,inputorder),vecfield(j,:),'UniformOutput',false);

			% If the higher-dimensional exterior derivative becomes useful,
			% replace the curl function here with that function (and maybe
			% write that function to be ndgrid compatible)
			curlfield = cell(1,size(basis_ordering,1));
			[curlfield{curl_ordering},junk] ...
				= curl(grid{inputorder},vecfield_meshgrid{:}); %#ok<NASGU>

			% Convert the data back into ndgrid ordering
			s.(['dA' Avec_names{i}])(j,:) = cellfun(@(x) permute(x,inputorder),curlfield,'UniformOutput',false);
			
		end
			
		% Duplicate the exterior derivative to initiate a
		% Lie-bracket corrected version
		s.(['DA' Avec_names{i}]) = s.(['dA' Avec_names{i}]);

		% Apply the lie bracket correction term
		correction = cell(n_rows,size(basis_ordering,1));
		for k = 1:size(basis_ordering,1)

			correction(:,k) = cellfun(@(x) x, se2_local_lie_bracket(vecfield(:,basis_ordering(k,1)),vecfield(:,basis_ordering(k,2))),'UniformOutput',false);

		end
		s.(['DA' Avec_names{i}]) ...
			= cellfun(@(x,y) x + y, s.(['DA' Avec_names{i}]), correction,'UniformOutput',false);
		
		
		%%%%%%%%%%
		% Get the percentage of the total constraint curvature contributed by
		% the exterior_derivative. First pair of lines calculates translational (using
		% pythagorean sum of x and y components). Final line gets
		% rotational (which should always be 1 for SE(2))
		s.(['DA' Avec_names{i} '_ratio']) =...
			{(s.(['dA' Avec_names{i}]){1}.^2+s.(['dA' Avec_names{i}]){2}.^2).^(.5)...
			./(s.(['DA' Avec_names{i}]){1}.^2+s.(['DA' Avec_names{i}]){2}.^2).^(.5);
			zeros(size(s.(['dA' Avec_names{i}]){2}));
			%
			s.(['dA' Avec_names{i}]){3}./s.(['DA' Avec_names{i}]){3}};
		
		
		

		% Make singularity-scaled versions
		if s.singularity
			
			for k = 1:numel(correction)
				
				temp = ...
					arctan_scale_vector_fields({s.(['dA' Avec_names{i}]){k}...
					,zeros(size(s.(['dA' Avec_names{i}]){k}))});
				
				s.(['dA' Avec_names{i} '_scaled']){k,1} = temp{1};
				
				temp = ...
					arctan_scale_vector_fields({s.(['DA' Avec_names{i}]){k}...
					, zeros(size(s.(['dA' Avec_names{i}]){k}))}); %.* (1-s.vecfield.eval.singularities{1});
			
				s.(['DA' Avec_names{i} '_scaled']){k,1} = temp{1};
				
			end
			
			
			% Scale the constraint curvature function nonconservative-to-total ratio values
			for k = 1:3
				
				temp = ...
					arctan_scale_vector_fields({s.(['DA' Avec_names{i} '_ratio']){k}...
					, zeros(size(s.(['dA' Avec_names{i}]){k}))}); %.* (1-s.vecfield.eval.singularities{1});
			
				s.(['DA' Avec_names{i} '_ratio_scaled']){k,1} = temp{1};
				
			end

		end
		
	end
	
end