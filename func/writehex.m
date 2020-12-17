function writehex(A, filename, bitWidth)
% WRITEHEX Write a matrix to a file, in hexadecimal representation format

% Conver to proper shape
A = A(:);
if ~isreal(A)
    A = [real(A), imag(A)].';
    A = A(:);
end

% Use wrap when overflow. Note this function can handle unsigned and signed
% value simultaneously
if (max(A) > 2^bitWidth - 1) || (min(A) < -2^(bitWidth - 1))
    warning('Bit width is to small to hold some of data, wrap is issued')
end
A = rem(A, 2^bitWidth);

% From R2020a dec2hex could handle negative numbers using two's complement
% binary values, but it does not produce arbitrary bit width. So manual
% converation is still needed.
A(A < 0) = A(A < 0) + 2^bitWidth;

numDigits = ceil(bitWidth/4);
A = dec2hex(A, numDigits);

writematrix(A, filename)

end
