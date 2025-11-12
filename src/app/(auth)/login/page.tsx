'use client';

import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setError(error.message);
    } else {
      router.push('/');
    }
  };

  return (
    <div className="relative flex h-auto min-h-screen w-full flex-col font-display dark group/design-root overflow-x-hidden">
      <main className="flex flex-col grow justify-center p-6">
        <div className="flex flex-col items-center text-center w-full max-w-md mx-auto">
          <div className="w-16 h-16 bg-primary rounded-full flex items-center justify-center mx-auto mb-8">
            <span className="material-symbols-outlined text-white text-4xl">send</span>
          </div>
          <h1 className="text-slate-900 dark:text-white tracking-tight text-[32px] font-bold leading-tight pb-2">Welcome Back!</h1>
          <p className="text-slate-600 dark:text-slate-300 text-base font-normal leading-normal pb-8">Log in to your account to continue.</p>
          <form className="w-full text-left space-y-4" onSubmit={handleLogin}>
            <div>
              <label className="text-slate-700 dark:text-slate-200 text-sm font-medium" htmlFor="email">Email</label>
              <input className="mt-1 block w-full rounded-lg border-0 bg-input-light dark:bg-input-dark text-slate-900 dark:text-white placeholder:text-foreground-light dark:placeholder:text-foreground-dark focus:ring-2 focus:ring-primary h-12" id="email" placeholder="e.g., you@example.com" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
            </div>
            <div>
              <div className="flex justify-between items-center">
                <label className="text-slate-700 dark:text-slate-200 text-sm font-medium" htmlFor="password">Password</label>
                <Link className="text-primary text-sm font-medium hover:underline" href="/forgot-password">Forgot Password?</Link>
              </div>
              <input className="mt-1 block w-full rounded-lg border-0 bg-input-light dark:bg-input-dark text-slate-900 dark:text-white placeholder:text-foreground-light dark:placeholder:text-foreground-dark focus:ring-2 focus:ring-primary h-12" id="password" placeholder="Enter your password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
            </div>
            {error && <p className="text-red-500 text-sm">{error}</p>}
            <div className="flex py-3 pt-6">
              <button type="submit" className="flex min-w-[84px] max-w-[480px] cursor-pointer items-center justify-center overflow-hidden rounded-lg h-12 px-5 flex-1 bg-primary text-white text-base font-bold leading-normal tracking-[0.015em]">
                <span className="truncate">Login</span>
              </button>
            </div>
          </form>
          <div className="mt-4">
            <p className="text-slate-500 dark:text-slate-400 text-sm font-normal leading-normal text-center">
              Don't have an account? <Link className="text-primary font-semibold hover:underline" href="/signup">Create Account</Link>
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
