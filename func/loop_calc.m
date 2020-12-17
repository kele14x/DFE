function [dn, g] = loop_calc(x, z, from, to, valid)
% use maximum match method to search loop delay
%
% [dn, g] = loop_calc(x, z, from, to, valid)

figure_on = true;

er = zeros(1, to-from);
% integer delay
for n = from:to - 1
    xd = sigdelay(x, n);
    [er(n + 1 - from), ~] = ercal(xd, z, valid);

    disp_wait(figure_on, '*');
end

disp_wait(figure_on, '\n');

figure;
plot(abs(er), '.-k');

[~, mn] = min(er);
dn_int = mn - 1 + from;

er = zeros(1, 64*2);
gn = zeros(1, 64*2);
% fractional delay
for n = -64:63
    xd = sigdelay(x, dn_int+n/64);
    [er(n + 65), gn(n + 65)] = ercal(xd, z, valid);

    disp_wait(figure_on, '+');
end

disp_wait(figure_on, '\n');

[~, mn] = min(er);
dn_fra = (mn - 65) / 64;

% result
dn = dn_int + dn_fra;
g = gn(mn);

end

%% -------------------------------------------------------------------------- %%
function [err_pwr, g] = ercal(x, y, valid)
% a * x = y, solve this function
x1 = x(valid);
y1 = y(valid);

% calc gain g * x = y
g = (y1 * x1') / (x1 * x1');

x2 = g * x;

err = x2 - y;
err_pwr = mean(abs(err(valid)).^2);
end

function disp_wait(figure_on, ch)

persistent id_
if (isempty(id_));
    id_ = 0;
end
id_ = id_ + 1;

if strcmp(ch, '\n')
    id_ = 0;
end

if figure_on
    fprintf(1, ch);
    if mod(id_, 40) == 0 && ~strcmp(ch, '\n')
        fprintf(1, '\n');
    end
end

end