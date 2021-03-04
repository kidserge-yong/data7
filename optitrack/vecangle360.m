function theta = vecangle360(p1,p2,p3)
    
    u = p1 - p2;
    v = p3 - p2;
    
    udotv = sum(u.*v); % dot product of u and v
    umag = norm(u); % vector magnitude of u
    vmag = norm(v); % vector magnitude of v
    
    
    theta = acos(udotv/(umag*vmag))*180/pi;

end