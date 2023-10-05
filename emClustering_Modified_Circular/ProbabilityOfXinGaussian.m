function [ prob ] = ProbabilityOfXinGaussian( x, mu, cov, pp )
%PROBABILITYOFXINGAUSSIAN Summary of this function goes here
%   Detailed explanation goes here

cov = cov(:);
mu = mu(:);
pp = pp(:);

diff = x - mu;
diff = mod(diff, 2*pi);
diff(diff>pi) = diff(diff>pi) - 2*pi;
diff(diff<-pi) = diff(diff<-pi) + 2*pi;

prob = exp(-((diff).^2)./(2*(cov)))./(sqrt(cov*2*pi)) .* pp;

end

