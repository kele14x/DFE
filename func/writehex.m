function writehex(A, filename, bitWidth)
% WRITEHEX Write a matrix to a file, in hexadecimal representation format

% Conver to proper shape
A = A(:);
if ~isreal(A)
    A = [real(A), imag(A)].';
    A = A(:);
end

% From R2020a dec2hex could handle negative numbers using two's complement
% binary values.
numDigits = ceil(bitWidth/4);
A = dec2hex(A, numDigits);

writematrix(A, filename)

end
