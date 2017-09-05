#include <TMB.hpp>

template<class Type>
vector<Type> get_response_probs(Type rt, Type mu1, Type mu2, Type sigma1, Type sigma2,
                                Type upper_a, Type upper_b, Type guess, Type habit)
{
  Type phi_a;
  Type phi_b;
  vector<Type> phi_all(4);
  matrix<Type> alpha(3, 4);
  
  phi_a = pnorm((rt - mu1)/sigma1);
  phi_b = pnorm((rt - mu2)/sigma2);
  phi_all(0) = (1 - phi_a) * (1 - phi_b);
  phi_all(1) = phi_a * (1 - phi_b);
  phi_all(2) = (1 - phi_a) * phi_b;
  phi_all(3) = phi_a * phi_b;
  
  alpha << guess, habit * (Type(1) - upper_a)/Type(3) + (Type(1) - habit) * guess, upper_b, upper_b,
           guess, habit * upper_a + (Type(1) - habit) * guess, (Type(1) - upper_b)/Type(3), (Type(1) - upper_b)/Type(3),
           Type(2) * (Type(0.5) * guess), 
           Type(2) * (habit * (Type(1) - upper_a)/Type(3) + (Type(1) - habit) * (Type(0.5) - guess)),
           Type(2) * ((Type(1) - upper_b)/Type(3)),
           Type(2) * ((Type(1) - upper_b)/Type(3));
  
  return alpha * phi_all;
}


template<class Type>
vector<Type> rmultinom(Type size, vector<Type> prob)
{
  // compare to https://github.com/SurajGupta/r-source/blob/master/src/nmath/rmultinom.c
  // and ?rmultinom
}
  
  
template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_MATRIX(y2); // 3 row, n column matrix (1 when chosen, 0 when not)
  DATA_VECTOR(rt);
  
  PARAMETER(mu1);
  PARAMETER(mu2);
  PARAMETER(sigma1);
  PARAMETER(sigma2);
  PARAMETER(upper_a);
  PARAMETER(upper_b);
  PARAMETER(guess);
  PARAMETER(habit);
  
  vector<Type> slice_y(3);
  
  Type nll = 0;
  
  for (int i=0; i < rt.size(); i++)
  {
    slice_y = y2.col(i); // hack because slice isn't proper type according to TMB
    nll -= dmultinom(slice_y, get_response_probs(rt(i), mu1, mu2, sigma1, sigma2, upper_a, upper_b, guess, habit), true);
    
    SIMULATE {
      // we can get "actual" responses with a call to rmultinom (which doesn't exist yet...)
      y2.col(i) = get_response_probs(rt(i), mu1, mu2, sigma1, sigma2, upper_a, upper_b, guess, habit);
    }
  }
  // penalization (keep sigma1, sigma2 from approaching zero)
  nll = nll + Type(1000) * pow(sigma1 - Type(0.07), 2) + Type(1000) * pow(sigma2 - Type(0.07), 2);

  SIMULATE {
    REPORT(y2);
  }
  return nll;
}
