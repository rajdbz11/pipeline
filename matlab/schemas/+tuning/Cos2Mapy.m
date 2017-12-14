%{
# pixelwise cosine fit to directional responses
-> tuning.OriMapy
---
cos2_amp                    : longblob                      # dF/F at preferred direction
cos2_r2                     : longblob                      # fraction of variance explained (after gaussinization)
cos2_fp                     : longblob                      # p-value of F-test (after gaussinization)
pref_ori                    : longblob                      # (radians) preferred direction
%}


classdef Cos2Mapy < dj.Computed

	methods(Access=protected)        

		function makeTuples(self, key)
            % check that angles are uniformly sampled
            [ndirs, C] = fetch1(tuning.Directional*tun Screen('PlayMovie', movie,1);ing.OriDesignMatrix & key, ...
                'ndirections', 'regressor_cov');
            phi = (0:ndirs-1)'/ndirs*360;            
            [B, R2, dof] = fetch1(tuning.OriMapy & key, ...
                'regr_coef_maps', 'r2_map', 'dof_map'); Screen('PlayMovie', movie,1);
            assert(size(B,3) == length(phi), 'OriMapy regression coeff dimension mismatch')
            sz = size(R2);
            B = reshape(B,[],length(phi));
            B = double(B);
            C = double(C);
            
            % compute cosine 2 response
            e = exp(1i*pi*phi/90)/sqrt(length(phi));
            b = B*e;
            F = real(2*b*e');    % cos2 tuning curves
            
            C = C^0.5;
            rv = sum((C*(B-F)').^2)./sum((C*B').^2);  % increase in variance due to fit
            R2 = max(0,1-rv)'.*R2(:);    % updated R-squared
            cos2DoF = 2; 
            Fp = 1-fcdf(R2.*(double(dof(:))-cos2DoF)/cos2DoF, cos2DoF, (double(dof(:))-cos2DoF));   % p-value of the F distribution
            
            key.cos2_amp = single(reshape(abs(b),sz));
            key.pref_ori = single(reshape(angle(b)/2,sz));
            key.cos2_r2  = single(reshape(R2,sz));
            key.cos2_fp  = single(reshape(Fp,sz));
            
			self.insert(key)
		end
    end
    
    
    methods
        function plot(self)
            for key = self.fetch()'
%                 g = fetch1(preprocess.PrepareGalvoAverageFrame & key & 'channel=1', 'frame');
%                 g = double(g);
%                 g = g - 0.8*imfilter(g,fspecial('gaussian',201,70));
%                 g = max(0,g-quantile(g(:),0.005));
%                 g = min(1,g/quantile(g(:),0.99));
                [amp, r2, ori, ~] = fetch1(tuning.Cos2Mapy & key, ...
                    'cos2_amp', 'cos2_r2', 'pref_ori', 'cos2_fp');
                amp = min(1,amp/quantile(amp(:),0.999)).^(0.8);
                h = mod(ori,pi)/pi;   % orientation is represented as hue
                s = max(0, min(1, amp/0.1));   % only significantly tuned pixels are shown in color
                v = ((max(0,r2)+0.002).^.2-0.002^.2)/0.3;  % brightness is proportional to variance explained, scaled between 0 and 10 %
                img = hsv2rgb(cat(3, h, s, max(0,min(v,1))));
                f = sprintf('cos2map-%05d-%03d-slice%u-%02d.png', ...
                    key.animal_id, key.scan_idx, key.slice, key.kernel);
                disp(['saving ' f])
                imwrite(img,f,'png')
            end
        end
    end

end
