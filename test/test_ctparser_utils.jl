function test_ctparser_utils()

# test utils
e = :( ∫( x(t)^2 + 2u[1](t)) → min )
@test prune_call(e, :x, :t) == :(∫(x ^ 2 + 2 * (u[1])(t)) → min)

e = :( ∫( x(t)^2 + 2u[1](t)) → min )
@test prune_call(e, :t) == :(∫(x ^ 2 + 2 * u[1]) → min)

e = :( ∫( r(t)^2 + 2u₁(t)) → min )
@test subs(e, :r, :( x[1] )) == :(∫((x[1])(t) ^ 2 + 2 * u₁(t)) → min)

e = :( ∫( u₁(t)^2 + 2u₂(t)) → min )
f = [ e, :foo, :foo ]
for i ∈ 1:2
     f[i+1] = subs(f[i], Symbol(:u, Char(8320+i)), :( u[$i] ))
end
@test f[3] == :(∫((u[1])(t) ^ 2 + 2 * (u[2])(t)) → min)

e = :( ∫( x[1](t)^2 + 2*u(t) ) → min )
@test has(e, :x, :t)
@test has(e, :u, :t)
@test !has(e, :v, :t)

t = :t; t0 = 0; tf = :tf; x = :x; u = :u;
@test constraint_type(:( x[1:2](0) ), t, t0, tf, x, u) == (:initial, 1:2)
@test constraint_type(:( x[1](0) ), t, t0, tf, x, u) == (:initial, 1)
@test constraint_type(:( x[1:2](tf) ), t, t0, tf, x, u) == (:final, 1:2)
@test constraint_type(:( x[1](tf) ), t, t0, tf, x, u) == (:final, 1)
@test constraint_type(:( x[1](tf) - x[2](0) ), t, t0, tf, x, u) == :boundary
@test constraint_type(:( u[1:2](t) ), t, t0, tf, x, u) == (:control_range, 1:2)
@test constraint_type(:( u[1](t) ), t, t0, tf, x, u) == (:control_range, 1)
@test constraint_type(:( 2u[1](t)^2 ), t, t0, tf, x, u) == :control_fun
@test constraint_type(:( x[1:2](t) ), t, t0, tf, x, u) == (:state_range, 1:2)
@test constraint_type(:( x[1](t) ), t, t0, tf, x, u) == (:state_range, 1)
@test constraint_type(:( 2x[1](t)^2 ), t, t0, tf, x, u) == :state_fun
@test constraint_type(:( 2u[1](t)^2 * x(t) ), t, t0, tf, x, u) == :mixed
@test constraint_type(:( 2u[1](0)^2 * x(t) ), t, t0, tf, x, u) == :other  

end