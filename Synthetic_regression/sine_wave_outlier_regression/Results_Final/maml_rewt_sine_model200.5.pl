��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2327161686640qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327161686256qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327161685968qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327161685584q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327161690096q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327161689520q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327161685584qX   2327161685968qX   2327161686256qX   2327161686640qX   2327161689520qX   2327161690096qe.(       ��zt�=�<�>������?s8���M:4������4�>�do��<ľ�d�/���2�<	c>e�W���?����� =�C�����+���R���h?���J>�#m>�����-����?�l)�ғ9�H&ĽdW�_=*�ƾ���Ο�>�Nվ@      �4�]�C��5޽�9���X�;���io��L�'�.���J-����KSȼq���� ����d⢽����ZQ+��<� �@:YjŽ�v�;��!�(���L�=���W^����Ľ��H�63�=�pv=��2�p�=4�<7�M>{mϽ�������#	� �I=�ڂ��)x= �ǻ~�]�}�s=�����=(X�<~��=��Q��(�2k=����M�<���=�M���f�'R>�5�7ʽO�=R�=�3?�j�� d�v��.�<�-���;3�=�ÍνU��=���ZzG=�Y�k&ѽ�<��	���^�d�I��Z׾���J��=R��>W�ݾ$>�<���?���x+�5z�>�k��zy�����9��]��>%)�>�\��AyM��	F��>�E�㧿�p�������C���g��ؾ�$����\<r[�ҫ��=������c���A��K&��@��Ņ�1K��f��=�~>, �=��-��5`b�)���9�!"F?���\-���<��=]J�>�2�u�>�1>W��=$�>&�7��gG��(�;b͎=I���,��������i�̾�G>@̾Ⱥ,�y�?��L>�S=�;$�5�w�8>9�����s�@�0��yP?cV>����b�=�b����=���먰?IL�=��=�=e=�:�>��ռ���=�~E�qAA��%սjK��$e=��	�;�2>@<�<��=�>St���P������ ��:I����5�.s-�C��ѡ=�C�J=�/=҆Q>�I���zƾ4X=3%?��)>����qKI���h����5�¾�;? [)��S=yI��p��G >�ľ�>xF=��ʽW�> *�;̌�����𽭽yܾ{���g>Ѭ���͂���:?*����`¾��ƻ3z*�b�G�L>��:��W�=6�ż_���\߾V�ٽ\��>E�c=����ž�JT>@�ξ��Կ���?�TA=8�+�k��=�[W�6����t�����\�x����˕��B:�'�����)=�@���R>)������h_�VǕ=�%�=�ɼ�y�m�/���Ǿ[/$�,B=
�#��X�9:��ʴ�= �2=��<�V�8���2��-��>o6��؇ݽ�#j�2Bɼ*Ƚ��=%�>fp����H�96��#��}u�i�輢�|��{3�)Q�<�4:=�qv��=���\�%�=8>0�T���3G��:,��� ��|�!N���F��D��闻>�W>"3����=���$�3����;)D|� �<K
��zL��>;���:��$�6�QT>O/Ծ	n�>��.=i�߼�)�>���ޛ�=<�X��w>�&�=FR8�>j_>�9?G��ZC=mQ�=qχ>�fI?q�0?��>��?x6H>p=]>u��>3"�>d�6��gn��n?@���,��߼H���;_����P���B?JF�>_m��0ُ��ž�J�����8?aΆ���?�����(��6/�F��
e�=�o�����#�g?��ҿ�����2U?�i=ҁʾ��Ԑ�pī�OO��,�ứ]�?�r��+7�<��`2���~�=�?�|��<lV���&�R�=tl2��P<��7=Vr����;�a+���<[\��ʆ=�0�Uu�4��=�����ҽ���~O���2�n/�4���~��p�O=;⌽/ט���q=��(�]ٗ�y����	=F�=S]S=�䅿�.Z�ד������մ?ӓ����>�?L�~u?�z���}⽢Ł=����N?p��:�4�޾O}ʽ_l�>�˄����C��م>�)潝̅>�.V��<��O<�9�0����>��;3r ��*�wVM>�-�>�9�>c%<m#�S.=S�~�&���L&����Hk�="2��G�;��L?��=TX�0�>�VM<`n���z<}E���%�=�PB�.D��%��wl�=��f<��J�,))���(=��]?Gx3=D�\�����>���������x��!3�:����W����F>�YG?&i���?����]p�0x>�TϠ�؃?��0=Hp_�N�=��l>~"?�g?�Y�>Y�?M�>c6h=ZǙ>[J?3>��?�.-?�3�=���>��I�mN�=n�5���>��=��q����=G8�=�w]�`���>t�l�A��m���p����*�ͱ�>�ڡ�l��p�>J�俰=��22=�����*?��2=}S>:$���}�=�ͷ�'_ѽ�-��`̇�����ھLj�}9	���y>�{ؾ$�4��#ɿ�9�
��n�>�������}��ӽ7q��*���	ֽ������<�˽ҐǾ� �= D���X���'���߾G����ㄿ�b���7`>g�=�='?���K�?��0�%jl����!	�����˾��i=[�!���>�H�!���K�迖����{=s?ig�������� �R=��ݿ�4��/�=�����N��'��̾=��>��|��N>�]8��fI�ƾ��v'g?|�߽v]��YЉ>w�5?$���uw>�*�=�+�=��
!�=�#?�p��^>�~�����>�V1?}�m=C�����S�� ;?�[>*t�=AYA>d�͖��#�ׁk?�wF�J�>̈��k�׾��\�ç��ި?�Ͻ[s��L^i���>@J�x�=���?TPѿ_ݐ�|���65A?,����O���~�?=�+��Q���#�i
��_���F�'>l�5�wv��C�=�ɾ\ս���n�J��h��<Ҳ ��S���i=�[���
���=��>q�P�NͿ�5��A��qs����!�X	?[ �>`��>!�&���W=�u�b�x�A*��̾�ֿP���IF�>	/?��=�� �UW�<����n�]�9?ҽ_�>^� � l�;ӻ0�4�L��d!���=�dk�i,N?⍁��T�$J3?��>-�ܾ�{ۿ�O=�����d��K�>�J?@�x���������n=n��>,���p]����E�Q�?�=��P���>�#>��&�1��#�B>C�߾U�������F�(��O�<"�.��=�E��v��>z�T��p4>-�>��)��ν���m[{� i=C缾3zd�ܫ��^���p�����1$����	���?=�����Q >��f����@�d>Kt޽���>D���t�����]���>��]�U]L�U������}�+>����_���0������{�<�[�<�f>B�	>��>G������Ch>E�^<��c��3ے��Bľ5��F?Ћ�=Df�M#��c(�:�>�~1�0������hY�<b���Gֽ�|�@�$<�KK�����=�2��%�7�O�_�ҕ��-Rѽ돼���z=a/,������<ʔ5=�Y>��>W���V����,=%g�S����W$=���)���5=�`�=���b�;Ɨ�=��p��W���Ȍ<H�����V>Ki���7�Z����Y���H��v�v�>�=��Ҽ��x�o_O�������n໽��=\w�9�N�q5c�0e��.-�J���$=w
K�M<�H�wzC���<���y��\�P�߾�v����y>,��OB6>iy��K�7���w=��@�H;'�Ž�����R=�y���W���_��@i���Y�B��m�H��<j�)�0<����<�r>�eV���+=��ͼ3:����<kd��>X��Ǟ� �5:��=�<Au<�^��=��𽸠`=��
P�!��;(?�����Hm&=Y����m����>��W�/W ��s���L�V^?ѡ>�Y<��>&}�=Ȕ�V9z�Aю�@�*>گ��B-�5ü��Z?kP�Rg�q$�@�.)B?��	�Sr
�Az���վ��Z>������5��=Q<&���r�L̈́�U�����?E�,�W2����{�����V�\>��=�T���7p>���?Mڥ=��=�k���d��p�>��	=zr�>:Ua��C>��)<�w�>�K1�te��L�̾د`�(sѼ�w�?��>�0+c=E��k>�ܾ�]���x>� ���#�]�������Y������J>�>4Mi������Xr�~h�=%�>�� =���@�
�'�V�ν���fB{?y���� ����=�)�;�~�wʡ��[�c_=���Quڽ��>�w<�Jy�=�T�=�h�=�=�	����������7>1�?��xĽ��
�t���C���8�/^��{߾��5�8�z��� ?�0>��Nin�;�	?�?�70?9�>)��>+xX=

x�|�q>'�?|$��8��>
�>?���>DR�=�I\���-;���=�,�>��d�Ў�<����U��(}�� �ݿ6�>�|����wLa��F��銾|<>'A�>HO!�z��>Zuƽ`�ݽ2e��=�Ⱦ/]=�%��ĉ�=q-��n��ܑ<w���Q*�d�S�.G<���U����t��q��>,罚��=c��=�/��>�<��>���<�o<���+��F�Dm�=�'�=�#=�
�=o�	��ɗ=��	=�1d��`�=Z&l��]>EQ�>~1$�a�
�����:>]A�@ذ������;2>2w޾f8�D�?>4�`��A����n>lp�<�f��@??�E��@=��<�Ƚt�=!>4H|�R�>q�(>Hz�>�_Ͼe�E�	A�>A�='��F޾O#5���8�o�,�^m�=g5�>�G�Y0�������F\��O����A><��>�)�?^�%=3�?6I���ᾙ;��?^M?����.>ڬ>v%��+�=u�&�5��(E�<TM$�t�?<�=��3?p��=�'^�t���ⱞ�Cd�����>$ƾLN����j>1��>.�����o���=r�нI���nؽ�.*����y*i>�V�<kx9�Z]���HV��=.��Z=��)��ƃ����Բ�` }�9��=V=O(�Iyj�Hi�<�2>B�=x�"=�,7���G���f��>���.h��1>R��P�{>B�A?��~<���>�>�=;,	>���=�c$�qz��3��������[H�=>	���Z������?Bi��<�� @=g��l��-�=v׽�����ܽ������=�=���=ʨ�>���$>ý�����hJ�v&�=Zk�=��Ƚ�w��=���#��>Ik*?
җ���;>;zI�3tl=3v>p#S�РC<���=L�=���=']���<�	d��}W��1μ�<�����=�d�
ܡ��h�<k%�=�v���Fu=:Y[��Y���=���=����\(q=���=�|����=���轾�X��)���߽�W��X��|&=��!�\���2b�=qnT�3��=Y�/�4�=T"A=�����=m���ePݾ};?������'�~þ8EԽ#�L>�Ό��Œ=@�S��eľxT�?�,��20=̷��o&���ؾ��\>�C���j<>G�=<�@�ch��cP�<J��>[��=�@�VR �{,?�Lec���?4�����?���8�;A�:=�[�;���r�=_�6�v�$=�������u���77��R�=���ȴY<����]�����=�J�#ܑ� ,R�A|��s8=��<Uν��9<�l�;��=�}��<=� �=�煼]罁d3��(o�g��=;z��4
� �<����ƾ�8	�涪>b����D9�r4:Ec�=z۬>�>#�>���>���<��1��@�>�D�>�D=�
�>� �=[I>�=�=[���x�>�. >(0Y�I�i>2I��.�=�c_>o�;�d�����>O7����=�j�=Q�s�B�ɼ���>�ý&ѽ`�>�G���I����<���=nt^��1�<��k�k�߽+-��i����Q��$�����=�'�=�[�X��X�Z<�J��=C����<"�"��_Ƽ ^��o���>���c���΀=��F�=�Í=Y�>�ǽӊ�Or;+n5�&��<�f��|�=$K	�=�)��2���_o=��!�99E�"{����>lDd���l�i������o>63�=�����H��X��'�=s^�Fo�>8�����������=��?!�La=�ξcB+>C�����TH=T}�n�X�qǿ�tx��2?cC�=���>�	�ȹK>�-��`h��(�;�A�u1�>N^�JL�?��=}[i�Y�)=��:=sVF�UX>��<� ��R��:^%x��d>2�=Ɉ�#���n��Y >;Qb?�۽C�>�C=�+h>���H�H�G噽�̣���$<�a�֪D�M��>�<�x�>O�ڼ�܏�(       U�>("<Le��N���?ÿ0 �>/��=Py�>�-=��={7?�hm�qK��Q>:z��.���� ?y@�=�-����v>G���h!�E:�>oN��*�d��E�*6�����=�%����Z�7=�B��|��?�F`��|����>ܲ����v>(       �*>��>Nu?��X=��M�`?�����������(�;˫\��,D�I��>�?�<+���?�,���<C�v�Q�^�V�A�'>:�=���G�5��Vi?@˽��?a�>�p>��n��?��=k��>�&��
��s!�(���š�GT^;,k�       ��߿(       8��:"��=Ը@�/ھ�94��؞��G���M�/%?*�/?M�p�ϊ�!��>���>0B޾Y9��CS?#B�?�?�9�J�h>�%5>���0G���r�.M�=��a��$?r/i=���?��N�Ҏ�=_�0>���<.�m>sHV�ӭ�>E�#<҉��H��<